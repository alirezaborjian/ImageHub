package test;

import model.*;
import service.*;
import util.Validator;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

public class BackendApplicationTest {

    private UserService userService;
    private AlbumService albumService;
    private AdminService adminService;
    private ImageService imageService;

    @BeforeEach
    public void setUp() {
        userService = new UserService();
        albumService = new AlbumService();
        adminService = new AdminService();
        imageService = new ImageService(new ArrayList<>());
    }

    @Test
    public void testValidPassword_Success() {
        assertTrue(Validator.isValidPassword("SecurePass123", "ali"));
    }

    @Test
    public void testPasswordTooShort_ReturnsFalse() {
        assertFalse(Validator.isValidPassword("Ab1", "ali"));
    }

    @Test
    public void testPasswordMissingNumber_ReturnsFalse() {
        assertFalse(Validator.isValidPassword("SecurePass", "ali"));
    }

    @Test
    public void testPasswordContainsUsername_ReturnsFalse() {
        assertFalse(Validator.isValidPassword("aliSecure123", "ali"));
    }

    @Test
    public void testRegisterUser_Success() {
        boolean isRegistered = userService.registerUser("reza", "Password123");
        assertTrue(isRegistered);
        assertNotNull(userService.getUser("reza"));
    }

    @Test
    public void testRegisterDuplicateUser_ReturnsFalse() {
        userService.registerUser("reza", "Password123");
        boolean isDuplicateRegistered = userService.registerUser("reza", "NewPass123");
        assertFalse(isDuplicateRegistered);
    }

    @Test
    public void testLoginUser_Success() {
        userService.registerUser("marian", "ValidPass1");
        User loggedInUser = userService.loginUser("marian", "ValidPass1");
        assertNotNull(loggedInUser);
        assertEquals("marian", loggedInUser.getUserName());
    }

    @Test
    public void testLoginUser_WrongPassword_ReturnsNull() {
        userService.registerUser("marian", "ValidPass1");
        User loggedInUser = userService.loginUser("marian", "WrongPass");
        assertNull(loggedInUser);
    }

    @Test
    public void testCreateAlbum_AddsToUserAlbums() {
        User user = new User("sara", "SaraPass1");
        Album album = albumService.creatAlbum(user, "Trip");

        assertNotNull(album);
        assertEquals("Trip", album.getTitle());
        assertTrue(user.getAlbums().contains(album));
    }

    @Test
    public void testAddImageToAlbum_EstablishesTwoWayRelation() {
        Album album = new Album("Nature");
        Image image = new Image("forest.jpg", "A rainy day");

        albumService.addImageToAlbum(album, image);

        assertTrue(album.getImages().contains(image));
        assertTrue(image.getAlbumTitles().contains("Nature"));
    }

    @Test
    public void testDeleteAlbum_CleansUpImageReferences() {
        User user = new User("sara", "SaraPass1");
        Album album = albumService.creatAlbum(user, "Private");
        Image image = new Image("me.jpg", "Profile pic");

        albumService.addImageToAlbum(album, image);
        albumService.deleteAlbum(user, album);

        assertFalse(user.getAlbums().contains(album));
        assertFalse(image.getAlbumTitles().contains("Private"));
    }

    @Test
    public void testBanUser_ChangesUserStatus() {
        User user = new User("bad_user", "UserPass1");
        assertFalse(user.isBanned());

        adminService.banUser(user);
        assertTrue(user.isBanned());
    }

    @Test
    public void testBannedUserCannotLogin() {
        userService.registerUser("hacker", "HackerPass1");
        User user = userService.getUser("hacker");

        adminService.banUser(user);

        User loggedInUser = userService.loginUser("hacker", "HackerPass1");
        assertNull(loggedInUser);
    }
}