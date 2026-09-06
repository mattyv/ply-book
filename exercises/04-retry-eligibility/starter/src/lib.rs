#[ply::ensures(|result| *result == (active < capacity))]
pub fn can_claim(active: u32, capacity: u32) -> bool {
    active < capacity
}
#[ply::requires(attempts <= max_attempts)]
#[ply::ensures(|result| *result == if attempts < max_attempts { attempts + 1 } else { max_attempts })]
pub fn apply_failure(attempts: u8, max_attempts: u8) -> u8 {
    attempts.saturating_add(1).min(max_attempts)
}
#[ply::ensures(|result| *result == 100 * (1u64 << attempt.min(3)))]
pub fn retry_delay_ms(attempt: u8) -> u64 {
    100 * (1u64 << attempt.min(3))
}
// TODO: write the complete retry eligibility postcondition.
pub fn is_retry_eligible(attempts: u8, max_attempts: u8, cancelled: bool) -> bool {
    let _ = (attempts, max_attempts);
    !cancelled // TODO: enforce the complete retry policy.
}
#[path = "../../../scheduler/src/lib.rs"]
pub mod scheduler;

#[cfg(test)]
mod tests {
    use super::is_retry_eligible;

    #[test]
    fn retry_requires_budget_and_no_cancellation() {
        assert!(is_retry_eligible(0, 1, false));
        assert!(!is_retry_eligible(0, 1, true));
        assert!(!is_retry_eligible(1, 1, false));
        assert!(!is_retry_eligible(2, 1, false));
    }
}
