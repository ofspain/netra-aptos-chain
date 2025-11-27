module dispute_os::dispute_errors {
    const ENOT_PUBLISHED: u64 = 0;
    const EALREADY_INITIALIZED: u64 = 1;
    const EMILESTONE_NOT_FOUND: u64 = 2;
    const EUNAUTHORIZED: u64 = 3;

    public fun enot_published(): u64 { ENOT_PUBLISHED }
    public fun ealready_initialized(): u64 { EALREADY_INITIALIZED }
    public fun emilestone_not_found(): u64 { EMILESTONE_NOT_FOUND }
    public fun eunauthorized(): u64 { EUNAUTHORIZED }
}
