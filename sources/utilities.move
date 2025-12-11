module dispute_os::dispute_utilities {
    use std::vector;
    
    /// Utility function to create an independent copy of a vector<u8>.
    public fun copy_vector_(source: &vector<u8>): vector<u8> {
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

    public fun copy_vector<T: copy>(source: &vector<T>): vector<T> {
        let len = vector::length(source);
        let copied = vector::empty<T>();
        let i = 0;

        while (i < len) {
            let val = *vector::borrow(source, i);
            vector::push_back(&mut copied, val);
            i = i + 1;
        };
        copied
}

}