package service;

import model.Album;
import model.Image;
import model.User;

public class AlbumService {
    public Album creatAlbum(User user, String title) {
        Album album = new Album(title);
        user.addAlbum(album);
        return album;
    }

    public void deleteAlbum(User user, Album album) {
        for (Image img : album.getImages()) {
            img.removeAlbumTitle(album.getTitle());
        }
        user.getAlbums().remove(album);
    }

    public void addImageToAlbum(Album album, Image image) {
        album.addImage(image);
        image.addAlbumTitle(album.getTitle());
    }
}