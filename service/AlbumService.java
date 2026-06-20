package service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import model.Album;
import model.User;
import model.Image;

public class AlbumService {
    public List<Image> images = new ArrayList<>();

    public enum SortBy {
        NAME,
        DATE,
        LIKES
    }

    public Album creatAlbum(User user, String title) {
        Album album = new Album(title);
        user.addAlbum(album);
        return album;
    }

    public void deleteAlbum(User user, Album album) {
        user.getAlbums().remove(album);
    }


    public void addImage(Image image) {
        images.add(image);
    }

    public void removeImage(Image image) {
        images.remove(image);
    }

    public List<Image> sortImages(SortBy sortBy) {
        Comparator<Image> comparator;

        switch (sortBy) {
            case NAME:
                comparator = Comparator.comparing(Image::getName);
                break;

            case DATE:
                comparator = Comparator.comparing(Image::getUploadDate).reversed();
                break;

            case LIKES:
                comparator = Comparator.comparingInt(Image::getLikes).reversed();
                break;

            default:
                comparator = Comparator.comparing(Image::getName);
        }

        return images.stream()
                .sorted(comparator)
                .collect(Collectors.toList());
    }


    public void moveImageOtherAlbum(Image image, Album NewAlbum) {
        boolean isRemoved = this.images.remove(image); 

        if (isRemoved) {
            NewAlbum.addImage(image);
            System.out.println("Successfully moved.");
        } else {
            System.out.println("Error.");
        }
    }

}
