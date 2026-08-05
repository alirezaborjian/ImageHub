package service;

import model.Album;
import model.Image;
import model.User;

import java.util.List;

public class AlbumService {

    private final List<Image> allImages;

    public AlbumService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public Album createAlbum(User user, String albumName) {
        if (user == null || albumName == null || albumName.trim().isEmpty()) {
            return null;
        }

        boolean exists = user.getAlbums().stream()
                .anyMatch(a -> a.getName() != null && a.getName().equalsIgnoreCase(albumName.trim()));

        if (exists) {
            return null;
        }

        String newId = String.valueOf(user.getAlbums().size() + 1);
        Album newAlbum = new Album(newId, albumName.trim(), user.getUserName());
        user.getAlbums().add(newAlbum);
        return newAlbum;
    }

    public boolean deleteAlbum(User user, Album album) {
        if (user == null || album == null) {
            return false;
        }
        return user.getAlbums().remove(album);
    }

    public boolean addImageToAlbum(Album album, Image image) {
        if (album == null || image == null) {
            return false;
        }

        boolean exists = album.getImages().stream()
                .anyMatch(i -> i.getTitle() != null && i.getTitle().equalsIgnoreCase(image.getTitle()));

        if (!exists) {
            album.addImage(image);
            return true;
        }
        return false;
    }

    public boolean removeImageFromAlbum(Album album, Image image) {
        if (album == null || image == null) {
            return false;
        }

        return album.getImages().removeIf(i -> i.getTitle() != null && i.getTitle().equalsIgnoreCase(image.getTitle()));
    }

    public boolean moveImageOtherAlbum(Album sourceAlbum, Album targetAlbum, Image image) {
        if (sourceAlbum == null || targetAlbum == null || image == null) {
            return false;
        }

        boolean removed = sourceAlbum.getImages().removeIf(i -> i.getTitle() != null && i.getTitle().equalsIgnoreCase(image.getTitle()));

        if (removed) {
            boolean existsInTarget = targetAlbum.getImages().stream()
                    .anyMatch(i -> i.getTitle() != null && i.getTitle().equalsIgnoreCase(image.getTitle()));

            if (!existsInTarget) {
                targetAlbum.addImage(image);
            }
            return true;
        }
        return false;
    }
}