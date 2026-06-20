package test;

import service.*;
import model.Album;
import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AlbumServiceTest {
    private AlbumService albumService;
    private User user;

    @BeforeEach
    public void setUp() {
        albumService = new AlbumService();
        user = new User("photographer", "pass123");
    }

    @Test
    public void testCreateAlbum() {
        Album album = albumService.creatAlbum(user, "Summer 2026");

        assertNotNull(album);
        assertEquals("Summer 2026", album.getTitle());
        assertEquals(1, user.getAlbums().size());
        assertEquals("Summer 2026", user.getAlbums().get(0).getTitle());
    }

    @Test
    public void testDeleteAlbum() {
        Album album = albumService.creatAlbum(user, "Trip to North");
        assertEquals(1, user.getAlbums().size());

        albumService.deleteAlbum(user, album);
        assertEquals(0, user.getAlbums().size());
    }
}