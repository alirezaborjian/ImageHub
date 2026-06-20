package service;

import model.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class ImageService {
    private List<Image> allImages;

    public enum SearchType {
        NAME,     
        DATE,     
        COMMENT,
        TAG,      
        ALL        
    }


    public ImageService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public void uploadImage(User user, Image image) {
        user.addImage(image);
        allImages.add(image);
    }

    public void likeImage(Image image) {
        image.like();
    }

    public void addComment(Image image, String userName, String text) {
        image.addComment(new Comment(userName, text));
    }


    public List<Image> search(SearchType type, String keyword) {

        switch (type) {
            case NAME:
   
                return allImages.stream()
                    .filter(img -> img.getName().toLowerCase().contains(keyword.toLowerCase()))
                    .collect(Collectors.toList());
                
            case COMMENT:
          
                return allImages.stream()
                    .filter(img -> img.getComments().contains(keyword))
                    .collect(Collectors.toList());
                
            case TAG:
      
                return allImages.stream()
                    .filter(img -> img.getTags().stream()
                        .anyMatch(tag -> tag.toLowerCase().contains(keyword.toLowerCase())))
                    .collect(Collectors.toList());
                
            default:
                return allImages; 
        }
    }

    

    
}