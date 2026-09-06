fn main() {
    for event in retry_eligibility_starter::scheduler::demo() {
        println!("{event}");
    }
}
