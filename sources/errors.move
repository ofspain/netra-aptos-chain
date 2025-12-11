module dispute_os::dispute_errors {
    const ENOT_PUBLISHED: u64 = 0;
    const EALREADY_INITIALIZED: u64 = 1;
    const E_NOT_FOUND: u64 = 2;
    const EUNAUTHORIZED: u64 = 3;
    const EUNILLEGALARGUMENT: u64 = 4;

    public fun enot_published(): u64 { ENOT_PUBLISHED }
    public fun ealready_initialized(): u64 { EALREADY_INITIALIZED }
    public fun not_found(): u64 { E_NOT_FOUND }
    public fun eunauthorized(): u64 { EUNAUTHORIZED }
    public fun eillegalargument(): u64 { EUNILLEGALARGUMENT }
}
