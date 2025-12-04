module dispute_os::copy_vector_test {
    use std::vector;
    use dispute_os::dispute_utilities;

    #[test]
    fun test_copy_vector_basic() {
        let original = b"hello";
        let copied = dispute_utilities::copy_vector(&original);

        // 1. Values must match
        assert!(vector::length(&copied) == vector::length(&original), 1);

        let i = 0;
        while (i < vector::length(&original)) {
            assert!(
                *vector::borrow(&copied, i) == *vector::borrow(&original, i),
                2
            );
            i = i + 1;
        };

        // 2. Mutating the copy must NOT mutate original
        vector::push_back(&mut copied, 33); // add '!' (33)

        assert!(
            vector::length(&original) == 5, // still "hello"
            3
        );
        assert!(
            vector::length(&copied) == 6, // "hello!"
            4
        );
    }
}
