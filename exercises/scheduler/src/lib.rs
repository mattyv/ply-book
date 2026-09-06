//! Shared in-memory scheduler used by every course exercise.

use std::collections::VecDeque;

#[derive(Debug)]
struct Job {
    name: &'static str,
    attempts: u8,
    max_attempts: u8,
    ready_at: u64,
    task: fn(u8) -> Result<(), ()>,
}

#[derive(Debug)]
pub struct Scheduler {
    capacity: u32,
    max_attempts: u8,
    queued: VecDeque<Job>,
}

impl Scheduler {
    pub fn new(capacity: u32, max_attempts: u8) -> Result<Self, &'static str> {
        if capacity == 0 || !(1..=4).contains(&max_attempts) {
            return Err("invalid scheduler limits");
        }
        Ok(Self {
            capacity,
            max_attempts,
            queued: VecDeque::new(),
        })
    }

    pub fn submit(
        &mut self,
        name: &'static str,
        task: fn(u8) -> Result<(), ()>,
    ) -> Result<(), &'static str> {
        if !super::can_claim(self.queued.len() as u32, self.capacity) {
            return Err("queue is full");
        }
        if self.queued.iter().any(|job| job.name == name) {
            return Err("duplicate pending job");
        }
        self.queued.push_back(Job {
            name,
            attempts: 0,
            max_attempts: self.max_attempts,
            ready_at: 0,
            task,
        });
        Ok(())
    }

    pub fn cancel(&mut self, name: &str) -> bool {
        self.queued
            .iter()
            .position(|job| job.name == name)
            .and_then(|index| self.queued.remove(index))
            .is_some()
    }

    pub fn process_next(&mut self, now_ms: u64) -> Option<String> {
        let position = self.queued.iter().position(|job| job.ready_at <= now_ms)?;
        let mut job = self.queued.remove(position)?;
        if (job.task)(job.attempts).is_ok() {
            return Some(format!("completed {}", job.name));
        }

        job.attempts = super::apply_failure(job.attempts, job.max_attempts);
        if super::is_retry_eligible(job.attempts, job.max_attempts, false) {
            let delay = super::retry_delay_ms(job.attempts.saturating_sub(1));
            let name = job.name;
            job.ready_at = now_ms.saturating_add(delay);
            self.queued.push_back(job);
            Some(format!("retry {name} in {delay}ms"))
        } else {
            Some(format!("failed {}", job.name))
        }
    }
}

pub fn demo() -> Vec<String> {
    fn report(attempt: u8) -> Result<(), ()> {
        if attempt < 2 {
            return Err(());
        }
        let total: u32 = [12, 8, 15].iter().sum();
        println!("report: processed {total} records");
        Ok(())
    }
    fn index(_: u8) -> Result<(), ()> {
        println!("index: refreshed");
        Ok(())
    }
    let mut scheduler = Scheduler::new(3, 3).unwrap();
    scheduler.submit("report", report).unwrap();
    scheduler.submit("index", index).unwrap();
    scheduler.submit("cancelled-report", report).unwrap();
    assert!(scheduler.cancel("cancelled-report"));
    let mut events = vec!["cancelled cancelled-report".into()];
    for now in [0, 0, 99, 100, 299, 300] {
        if let Some(event) = scheduler.process_next(now) {
            events.push(format!("{now}ms: {event}"));
        }
    }
    events
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn delayed_retries_do_not_block_ready_jobs() {
        fn fail_once(attempt: u8) -> Result<(), ()> {
            if attempt == 0 { Err(()) } else { Ok(()) }
        }
        fn succeeds(_: u8) -> Result<(), ()> {
            Ok(())
        }
        let mut scheduler = Scheduler::new(3, 2).unwrap();
        scheduler.submit("alpha", fail_once).unwrap();
        scheduler.submit("beta", succeeds).unwrap();
        assert_eq!(
            scheduler.process_next(0).as_deref(),
            Some("retry alpha in 100ms")
        );
        assert_eq!(scheduler.process_next(0).as_deref(), Some("completed beta"));
        assert_eq!(scheduler.process_next(99), None);
        assert_eq!(
            scheduler.process_next(100).as_deref(),
            Some("completed alpha")
        );
        assert_eq!(scheduler.process_next(100), None);
    }

    #[test]
    fn a_cancelled_queued_job_is_not_retried() {
        fn succeeds(_: u8) -> Result<(), ()> {
            Ok(())
        }
        let mut scheduler = Scheduler::new(1, 2).unwrap();
        scheduler.submit("alpha", succeeds).unwrap();
        assert!(scheduler.cancel("alpha"));
        assert_eq!(scheduler.process_next(0), None);
    }

    #[test]
    fn queue_limits_duplicates_and_cancellation() {
        fn succeeds(_: u8) -> Result<(), ()> {
            Ok(())
        }
        assert!(Scheduler::new(0, 1).is_err());
        assert!(Scheduler::new(1, 0).is_err());
        assert!(Scheduler::new(1, 5).is_err());
        let mut scheduler = Scheduler::new(2, 1).unwrap();
        scheduler.submit("alpha", succeeds).unwrap();
        assert_eq!(
            scheduler.submit("alpha", succeeds),
            Err("duplicate pending job")
        );
        scheduler.submit("beta", succeeds).unwrap();
        assert_eq!(scheduler.submit("gamma", succeeds), Err("queue is full"));
        assert!(scheduler.cancel("alpha"));
        assert!(!scheduler.cancel("alpha"));
        scheduler.submit("gamma", succeeds).unwrap();
        assert_eq!(scheduler.process_next(0).as_deref(), Some("completed beta"));
        assert_eq!(
            scheduler.process_next(0).as_deref(),
            Some("completed gamma")
        );
        assert_eq!(scheduler.process_next(0), None);
    }

    #[test]
    fn failures_exhaust_each_supported_budget_with_increasing_delays() {
        fn fails(_: u8) -> Result<(), ()> {
            Err(())
        }
        for max_attempts in 1..=4 {
            let mut scheduler = Scheduler::new(1, max_attempts).unwrap();
            scheduler.submit("alpha", fails).unwrap();
            let mut now = 0;
            for attempt in 1..max_attempts {
                let delay = 100u64 << (attempt - 1);
                assert_eq!(
                    scheduler.process_next(now),
                    Some(format!("retry alpha in {delay}ms"))
                );
                assert_eq!(scheduler.process_next(now + delay - 1), None);
                now += delay;
            }
            assert_eq!(scheduler.process_next(now).as_deref(), Some("failed alpha"));
            assert_eq!(scheduler.process_next(u64::MAX), None);
        }
    }
}
