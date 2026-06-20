package test;

import service.*;
import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.ArrayList;
import static org.junit.jupiter.api.Assertions.*;

public class UserServiceTest {
    private UserService userService;

    @BeforeEach
    public void setUp() {
        userService = new UserService(new ArrayList<>());
    }

    @Test
    public void testRegister_Success() {
        boolean result = userService.register("ali", "Pass1234");
        assertTrue(result);
        assertEquals(1, userService.getUsers().size());
    }

    @Test
    public void testRegister_DuplicateUser_ReturnsFalse() {
        userService.register("ali", "Pass1234");
        boolean result = userService.register("ali", "DifferentPass");
        assertFalse(result);
        assertEquals(1, userService.getUsers().size());
    }

    @Test
    public void testLogin_Success() {
        userService.register("reza", "mypassword");
        User loggedInUser = userService.login("reza", "mypassword");
        assertNotNull(loggedInUser);
        assertEquals("reza", loggedInUser.getUserName());
    }

    @Test
    public void testLogin_WrongPassword_ReturnsNull() {
        userService.register("reza", "mypassword");
        User loggedInUser = userService.login("reza", "wrongpass");
        assertNull(loggedInUser);
    }

    @Test
    public void testFindUser_ExistingAndNonExisting() {
        userService.register("sara", "1234");
        assertNotNull(userService.findUser("sara"));
        assertNull(userService.findUser("unknown_user"));
    }
}