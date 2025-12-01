script {
    use dispute_os::dispute_lifecycle;
    
    fun main(admin: signer) {
        dispute_lifecycle::init_system(&admin);
    }
}