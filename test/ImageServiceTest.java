package test;

import service.*;
import model.Image;
import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.ArrayList;
import static org.junit.jupiter.api.Assertions.*;

public class ImageServiceTest {
    private ImageService imageService;
    private User user;

    @BeforeEach
    public void setUp() {
        imageService = new ImageService(new ArrayList<>());
        user = new User("john_doe", "password");
    }

    @Test
    public void testUploadImage() {
        Image image = new Image("nature.jpg", "Beautiful sunset");
        imageService.uploadImage(user, image);

        assertEquals(1, user.getUploadImages().size());
        assertEquals("nature.jpg", user.getUploadImages().get(0).getName());
    }

    @Test
    public void testLikeImage() {
        Image image = new Image("car.jpg", "Fast car");
        assertEquals(0, image.getLikes());

        imageService.likeImage(image);
        assertEquals(1, image.getLikes());
    }

    @Test
    public void testAddComment() {
        Image image = new Image("food.jpg", "Yummy!");
        imageService.addComment(image, "alice", "Looks delicious!");

        assertEquals(1, image.getComments().size());
        assertEquals("alice", image.getComments().get(0).getUserName());
        assertEquals("Looks delicious!", image.getComments().get(0).getText());
    }
}