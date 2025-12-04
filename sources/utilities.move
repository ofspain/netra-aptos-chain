module dispute_os::dispute_utilities {
    use std::vector;
    
    /// Utility function to create an independent copy of a vector<u8>.
    public fun copy_vector(source: &vector<u8>): vector<u8> {
        let len = vector::length(source);
        let i = 0;
        let copied = vector::empty<u8>();
    
        // Manually copy each byte
        while (i < len) {
            let byte = *vector::borrow(source, i);
            vector::push_back(&mut copied, byte);
            i = i + 1;
        };
        copied
    }
}