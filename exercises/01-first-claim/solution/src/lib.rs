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
#[ply::ensures(|result| *result == (!cancelled && attempts < max_attempts))]
pub fn is_retry_eligible(attempts: u8, max_attempts: u8, cancelled: bool) -> bool {
    !cancelled && attempts < max_attempts
}
#[path = "../../../scheduler/src/lib.rs"]
pub mod scheduler;

#[cfg(test)]
mod tests {
    use super::can_claim;

    #[test]
    fn admission_respects_the_capacity_boundary() {
        for (active, capacity, expected) in [
            (0, 1, true),
            (2, 3, true),
            (3, 3, false),
            (4, 3, false),
            (0, 0, false),
        ] {
            assert_eq!(can_claim(active, capacity), expected);
        }
    }
}
