package util;

import model.Album;
import model.Image;
import model.User;
import util.DatabaseManager;

import java.util.List;
import java.util.Scanner;

public class AdminConsole {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        boolean running = true;

        while (running) {
            System.out.println("\n--- ImageHub Admin Panel ---");
            System.out.println("1. Display all users");
            System.out.println("2. Display all images");
            System.out.println("3. Display user details (images and albums)");
            System.out.println("4. Delete a user");
            System.out.println("5. Delete an image");
            System.out.println("6. Exit");
            System.out.print("Please select an option: ");

            String choice = scanner.nextLine().trim();

            List<User> users = DatabaseManager.loadUsers();
            List<Image> images = DatabaseManager.loadImages();

            switch (choice) {
                case "1":
                    System.out.println("\n--- Registered Users List ---");
                    if (users.isEmpty()) {
                        System.out.println("No users found.");
                    } else {
                        for (int i = 0; i < users.size(); i++) {
                            User u = users.get(i);
                            System.out.println((i + 1) + ". Username: " + u.getUserName() +
                                    " | Email: " + (u.getEmail() != null ? u.getEmail() : "N/A") +
                                    " | Admin: " + (u.isAdmin() ? "Yes" : "No"));
                        }
                    }
                    break;

                case "2":
                    System.out.println("\n--- All Uploaded Images ---");
                    if (images.isEmpty()) {
                        System.out.println("No images found.");
                    } else {
                        for (int i = 0; i < images.size(); i++) {
                            Image img = images.get(i);
                            System.out.println((i + 1) + ". Title: " + img.getTitle() +
                                    " | Uploader: " + img.getUploader() +
                                    " | Date: " + img.getUploadDate() +
                                    " | Likes: " + (img.getLikes() != null ? img.getLikes().size() : 0));
                        }
                    }
                    break;

                case "3":
                    System.out.print("Enter target username: ");
                    String targetUsername = scanner.nextLine().trim();
                    User foundUser = users.stream()
                            .filter(u -> u.getUserName() != null && u.getUserName().equalsIgnoreCase(targetUsername))
                            .findFirst()
                            .orElse(null);

                    if (foundUser == null) {
                        System.out.println("User not found.");
                    } else {
                        System.out.println("\n--- User Details: " + foundUser.getUserName() + " ---");
                        System.out.println("Uploaded images count: " + foundUser.getUploadImages().size());
                        for (Image img : foundUser.getUploadImages()) {
                            System.out.println(" - Image: " + img.getTitle());
                        }

                        System.out.println("Albums count: " + foundUser.getAlbums().size());
                        for (Album alb : foundUser.getAlbums()) {
                            System.out.println(" - Album: " + alb.getName() + " (Images count: " + alb.getImages().size() + ")");
                        }
                    }
                    break;

                case "4":
                    System.out.print("Enter username to delete: ");
                    String delUsername = scanner.nextLine().trim();
                    boolean removedUser = users.removeIf(u -> u.getUserName() != null && u.getUserName().equalsIgnoreCase(delUsername));

                    if (removedUser) {
                        DatabaseManager.saveData(users, images);
                        System.out.println("User deleted successfully and changes saved.");
                    } else {
                        System.out.println("User not found.");
                    }
                    break;

                case "5":
                    System.out.print("Enter image title to delete: ");
                    String delImageTitle = scanner.nextLine().trim();
                    boolean removedImage = images.removeIf(img -> img.getTitle() != null && img.getTitle().equalsIgnoreCase(delImageTitle));

                    if (removedImage) {
                        for (User u : users) {
                            if (u.getUploadImages() != null) {
                                u.getUploadImages().removeIf(img -> img.getTitle() != null && img.getTitle().equalsIgnoreCase(delImageTitle));
                            }
                            if (u.getAlbums() != null) {
                                for (Album alb : u.getAlbums()) {
                                    if (alb.getImages() != null) {
                                        alb.getImages().removeIf(img -> img.getTitle() != null && img.getTitle().equalsIgnoreCase(delImageTitle));
                                    }
                                }
                            }
                        }
                        DatabaseManager.saveData(users, images);
                        System.out.println("Image deleted successfully from the system.");
                    } else {
                        System.out.println("Image not found.");
                    }
                    break;

                case "6":
                    running = false;
                    System.out.println("Exiting admin panel.");
                    break;

                default:
                    System.out.println("Invalid option. Please enter a number between 1 and 6.");
                    break;
            }
        }
        scanner.close();
    }
}