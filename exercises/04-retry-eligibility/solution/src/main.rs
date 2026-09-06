fn main() {
    for event in retry_eligibility_solution::scheduler::demo() {
        println!("{event}");
    }
}
