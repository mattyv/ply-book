#[ply::ensures(|result| *result == (active < capacity))]
pub fn can_claim(active: u32, capacity: u32) -> bool {
    active < capacity
}
#[ply::requires(attempts <= max_attempts)]
#[ply::ensures(|result| *result == if attempts < max_attempts { attempts + 1 } else { max_attempts })]
pub fn apply_failure(attempts: u8, max_attempts: u8) -> u8 {
    attempts // TODO: record this failure.
}
// A later lesson writes this decision's promise.
pub fn retry_delay_ms(attempt: u8) -> u64 {
    100 * (1u64 << attempt.min(3))
}
// A later lesson writes this decision's promise.
pub fn is_retry_eligible(attempts: u8, max_attempts: u8, cancelled: bool) -> bool {
    !cancelled && attempts < max_attempts
}
#[path = "../../../scheduler/src/lib.rs"]
pub mod scheduler;

#[cfg(test)]
mod tests {
    use super::apply_failure;

    #[test]
    fn first_failure_uses_one_attempt() {
        assert_eq!(apply_failure(0, 3), 1);
    }
}
