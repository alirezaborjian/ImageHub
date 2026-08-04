package service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import model.*;
import util.DatabaseManager;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.Base64;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class APIServer {
    private static final int PORT = 8085;
    private static List<User> users;
    private static List<Image> allImages;
    private static Set<User> bannedUsers;

    private static UserService userService;
    private static ImageService imageService;
    private static AlbumService albumService;
    private static final Gson gson = new Gson();
    private static final String PICS_DIR = "pictures/";

    public static void main(String[] args) {
        users = Collections.synchronizedList(DatabaseManager.loadUsers());
        allImages = Collections.synchronizedList(DatabaseManager.loadImages());
        bannedUsers = Collections.synchronizedSet(new HashSet<>());

        userService = new UserService();
        imageService = new ImageService(allImages);
        albumService = new AlbumService(allImages);

        try {
            Files.createDirectories(Paths.get(PICS_DIR));
        } catch (IOException e) {
            e.printStackTrace();
        }

        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("ImageHub APIServer started on port " + PORT);
            while (true) {
                Socket clientSocket = serverSocket.accept();
                new Thread(new ClientHandler(clientSocket)).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static class ClientHandler implements Runnable {
        private final Socket socket;

        public ClientHandler(Socket socket) {
            this.socket = socket;
        }

        @Override
        public void run() {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                 PrintWriter out = new PrintWriter(socket.getOutputStream(), true)) {

                String inputLine;
                if ((inputLine = in.readLine()) != null) {
                    String response = handleRequest(inputLine);
                    out.println(response);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        private String handleRequest(String jsonRequest) {
            JsonObject response = new JsonObject();
            try {
                JsonObject request = JsonParser.parseString(jsonRequest).getAsJsonObject();
                if (!request.has("action")) {
                    response.addProperty("statusCode", 400);
                    response.addProperty("message", "Action parameters missing.");
                    return gson.toJson(response);
                }

                String action = request.get("action").getAsString();

                switch (action) {
                    case "signup": {
                        String sUser = request.has("username") ? request.get("username").getAsString() : "";
                        String sPass = request.has("password") ? request.get("password").getAsString() : "";
                        return userService.registerUser(sUser, sPass, "", users);
                    }

                    case "login": {
                        String lUser = request.has("username") ? request.get("username").getAsString() : "";
                        String lPass = request.has("password") ? request.get("password").getAsString() : "";
                        return userService.loginUser(lUser, lPass, users);
                    }

                    case "logout": {
                        response.addProperty("statusCode", 200);
                        response.addProperty("message", "Logged out successfully.");
                        break;
                    }

                    case "getAllImages": {
                        JsonArray imgArray = new JsonArray();
                        for (Image img : allImages) {
                            JsonObject imgObj = new JsonObject();
                            imgObj.addProperty("name", img.getTitle() != null ? img.getTitle() : "");
                            imgObj.addProperty("caption", "");

                            String base64Content = "";
                            if (img.getImagePath() != null) {
                                try {
                                    byte[] fileBytes = Files.readAllBytes(Paths.get(img.getImagePath()));
                                    base64Content = Base64.getEncoder().encodeToString(fileBytes);
                                } catch (IOException e) {
                                    base64Content = "";
                                }
                            }

                            imgObj.addProperty("imageUrl", base64Content);
                            imgObj.addProperty("likes", img.getLikes() != null ? img.getLikes().size() : 0);
                            imgArray.add(imgObj);
                        }

                        response.addProperty("statusCode", 200);
                        response.addProperty("message", "Images retrieved successfully.");
                        response.add("payload", imgArray);
                        break;
                    }

                    case "uploadImage": {
                        String imgName = request.get("name").getAsString();
                        String caption = request.has("caption") ? request.get("caption").getAsString() : "";
                        String base64Data = request.get("base64Data").getAsString();
                        String uName = request.has("username") ? request.get("username").getAsString() : "";

                        User u = users.stream()
                                .filter(user -> user.getUserName() != null
                                        && user.getUserName().equalsIgnoreCase(uName.trim()))
                                .findFirst()
                                .orElse(null);

                        if (u == null) {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "User not found.");
                            break;
                        }

                        String cleanBase64 = base64Data.contains(",") ? base64Data.split(",")[1] : base64Data;

                        String imgPath = PICS_DIR + imgName + ".jpg";
                        byte[] imageBytes = Base64.getDecoder().decode(cleanBase64);
                        Files.write(Paths.get(imgPath), imageBytes);

                        String newId = String.valueOf(allImages.size() + 1);
                        Image image = new Image(newId, imgName, imgPath, u.getUserName(), LocalDate.now().toString());
                        imageService.uploadImage(u, image);

                        JsonObject imgObj = new JsonObject();
                        imgObj.addProperty("name", image.getTitle());
                        imgObj.addProperty("caption", caption);
                        imgObj.addProperty("imageUrl", cleanBase64);

                        response.addProperty("statusCode", 200);
                        response.addProperty("message", "Image uploaded successfully.");
                        response.add("payload", imgObj);
                        break;
                    }

                    case "deleteImage": {
                        String delImgUser = request.get("username").getAsString();
                        String delImgName = request.get("name").getAsString();
                        User delUserObj = users.stream()
                                .filter(usr -> usr.getUserName() != null
                                        && usr.getUserName().equalsIgnoreCase(delImgUser.trim()))
                                .findFirst()
                                .orElse(null);

                        if (delUserObj != null) {
                            Image imgToDelete = allImages.stream()
                                    .filter(i -> i.getTitle() != null && i.getTitle().equals(delImgName))
                                    .findFirst()
                                    .orElse(null);

                            if (imgToDelete != null) {
                                if (imgToDelete.getImagePath() != null) {
                                    try {
                                        Files.deleteIfExists(Paths.get(imgToDelete.getImagePath()));
                                    } catch (IOException ignored) {
                                    }
                                }
                                allImages.remove(imgToDelete);
                                if (delUserObj.getUploadImages() != null) {
                                    delUserObj.getUploadImages().remove(imgToDelete);
                                }
                                if (delUserObj.getAlbums() != null) {
                                    for (Album alb : delUserObj.getAlbums()) {
                                        if (alb.getImages() != null) {
                                            alb.getImages().remove(imgToDelete);
                                        }
                                    }
                                }
                                response.addProperty("statusCode", 200);
                                response.addProperty("message", "Image deleted successfully.");
                            } else {
                                response.addProperty("statusCode", 404);
                                response.addProperty("message", "Image not found.");
                            }
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "User not found.");
                        }
                        break;
                    }

                    case "likeImage": {
                        String targetImgName = request.get("name").getAsString();
                        String likerUser = request.get("username").getAsString();
                        Image imgToLike = allImages.stream()
                                .filter(img -> img.getTitle() != null && img.getTitle().equals(targetImgName))
                                .findFirst()
                                .orElse(null);

                        if (imgToLike != null) {
                            imageService.likeImage(imgToLike, likerUser);
                            response.addProperty("statusCode", 200);
                            response.addProperty("message", "Like status updated.");
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "Image not found.");
                        }
                        break;
                    }

                    case "addComment": {
                        String cImgName = request.get("name").getAsString();
                        String commenter = request.get("username").getAsString();
                        // بررسی برای پشتیبانی از هر دو کلید "comment" و "text"
                        String text = request.has("comment") ? request.get("comment").getAsString()
                                : (request.has("text") ? request.get("text").getAsString() : "");

                        Image imgToComment = allImages.stream()
                                .filter(img -> img.getTitle() != null && img.getTitle().equals(cImgName))
                                .findFirst()
                                .orElse(null);

                        if (imgToComment != null) {
                            imageService.addComment(imgToComment, commenter, text);
                            response.addProperty("statusCode", 200);
                            response.addProperty("message", "Comment added.");
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "Image not found.");
                        }
                        break;
                    }

                    case "addTag": {
                        String tagImgName = request.get("name").getAsString();
                        String tagText = request.get("tag").getAsString();

                        Image imgToTag = allImages.stream()
                                .filter(img -> img.getTitle() != null && img.getTitle().equals(tagImgName))
                                .findFirst()
                                .orElse(null);

                        if (imgToTag != null) {
                            // اضافه کردن تگ به مدل و متد مربوطه
                            imageService.addTag(imgToTag, tagText);
                            response.addProperty("statusCode", 200);
                            response.addProperty("message", "Tag added successfully.");
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "Image not found.");
                        }
                        break;
                    }

                    case "createAlbum": {
                        String albUser = request.get("username").getAsString();
                        String albTitle = request.get("title").getAsString();
                        User owner = users.stream()
                                .filter(usr -> usr.getUserName() != null
                                        && usr.getUserName().equalsIgnoreCase(albUser.trim()))
                                .findFirst()
                                .orElse(null);
                        if (owner != null) {
                            Album newAlbum = albumService.createAlbum(owner, albTitle);
                            if (newAlbum != null) {
                                response.addProperty("statusCode", 200);
                                response.addProperty("message", "Album created successfully.");
                            } else {
                                response.addProperty("statusCode", 400);
                                response.addProperty("message", "Album already exists.");
                            }
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "User not found.");
                        }
                        break;
                    }

                    case "deleteAlbum": {
                        String delUser = request.get("username").getAsString();
                        String delTitle = request.get("title").getAsString();
                        User dOwner = users.stream()
                                .filter(usr -> usr.getUserName() != null
                                        && usr.getUserName().equalsIgnoreCase(delUser.trim()))
                                .findFirst()
                                .orElse(null);
                        if (dOwner != null) {
                            Album targetAlbum = dOwner.getAlbums().stream()
                                    .filter(a -> a.getName() != null && a.getName().equalsIgnoreCase(delTitle))
                                    .findFirst()
                                    .orElse(null);
                            if (targetAlbum != null) {
                                albumService.deleteAlbum(dOwner, targetAlbum);
                                response.addProperty("statusCode", 200);
                                response.addProperty("message", "Album deleted successfully.");
                            } else {
                                response.addProperty("statusCode", 404);
                                response.addProperty("message", "Album not found.");
                            }
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "User not found.");
                        }
                        break;
                    }

                    case "removeImageFromAlbum": {
                        String remUser = request.get("username").getAsString();
                        String remTitle = request.get("title").getAsString();
                        String remImgName = request.get("name").getAsString();
                        User remOwner = users.stream()
                                .filter(usr -> usr.getUserName() != null
                                        && usr.getUserName().equalsIgnoreCase(remUser.trim()))
                                .findFirst()
                                .orElse(null);
                        if (remOwner != null) {
                            Album remAlb = remOwner.getAlbums().stream()
                                    .filter(a -> a.getName() != null && a.getName().equalsIgnoreCase(remTitle))
                                    .findFirst()
                                    .orElse(null);
                            if (remAlb != null) {
                                remAlb.getImages()
                                        .removeIf(i -> i.getTitle() != null && i.getTitle().equals(remImgName));
                                response.addProperty("statusCode", 200);
                                response.addProperty("message", "Image removed from album.");
                            } else {
                                response.addProperty("statusCode", 404);
                                response.addProperty("message", "Album not found.");
                            }
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "User not found.");
                        }
                        break;
                    }

                    case "moveImage": {
                        String mUser = request.get("username").getAsString();
                        String srcTitle = request.get("sourceAlbum").getAsString();
                        String destTitle = request.get("targetAlbum").getAsString();
                        String targetImg = request.get("imageName").getAsString();
                        User mOwner = users.stream()
                                .filter(usr -> usr.getUserName() != null
                                        && usr.getUserName().equalsIgnoreCase(mUser.trim()))
                                .findFirst()
                                .orElse(null);
                        if (mOwner != null) {
                            Album srcAlb = mOwner.getAlbums().stream()
                                    .filter(a -> a.getName() != null && a.getName().equalsIgnoreCase(srcTitle))
                                    .findFirst().orElse(null);
                            Album destAlb = mOwner.getAlbums().stream()
                                    .filter(a -> a.getName() != null && a.getName().equalsIgnoreCase(destTitle))
                                    .findFirst().orElse(null);
                            Image target = allImages.stream()
                                    .filter(i -> i.getTitle() != null && i.getTitle().equals(targetImg)).findFirst()
                                    .orElse(null);
                            if (srcAlb != null && destAlb != null && target != null) {
                                boolean moved = albumService.moveImageOtherAlbum(srcAlb, destAlb, target);
                                if (moved) {
                                    response.addProperty("statusCode", 200);
                                    response.addProperty("message", "Image moved successfully.");
                                } else {
                                    response.addProperty("statusCode", 400);
                                    response.addProperty("message", "Failed to move image.");
                                }
                            } else {
                                response.addProperty("statusCode", 404);
                                response.addProperty("message", "Source/Destination album or image not found.");
                            }
                        } else {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "User not found.");
                        }
                        break;
                    }

                    default:
                        response.addProperty("statusCode", 400);
                        response.addProperty("message", "Unknown action");
                }
            } catch (Exception e) {
                response.addProperty("statusCode", 500);
                response.addProperty("message", e.getMessage());
            }

            // ذخیره‌سازی خودکار تمام تغییرات (شامل لایک، کامنت و تگ) در فایل‌های JSON
            DatabaseManager.saveData(users, allImages);
            return gson.toJson(response);
        }
    }
}