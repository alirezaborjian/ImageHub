package tset;

import util.Validator;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class ValidatorTest {

    @Test
    public void testIsValidPassword_InvalidPasswords() {
        assertFalse(Validator.isValidPassword("short"));
        assertFalse(Validator.isValidPassword("12345678"));
        assertFalse(Validator.isValidPassword("abcdefgh"));
    }
}