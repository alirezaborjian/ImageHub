package util;

import service.*;
import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.HashSet;
import static org.junit.jupiter.api.Assertions.*;

public class AdminServiceTest {
    private AdminService adminService;

    @BeforeEach
    public void setUp() {
        adminService = new AdminService(new HashSet<>());
    }

    @Test
    public void testBanUserAndIsBanned() {
        User user = new User("bad_user", "12345");

        assertFalse(adminService.isBanned("bad_user"));

        adminService.banUser(user);

        assertTrue(adminService.isBanned("bad_user"));
    }
}