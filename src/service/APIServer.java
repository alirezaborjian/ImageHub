package service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import model.*;
import util.DatabaseManager;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
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
            try (BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
                 BufferedWriter out = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), StandardCharsets.UTF_8))) {

                String inputLine;
                if ((inputLine = in.readLine()) != null) {
                    String response = handleRequest(inputLine);
                    out.write(response);
                    out.newLine();
                    out.flush();
                }
            } catch (IOException e) {
                System.err.println("Socket error: " + e.getMessage());
            } finally {
                try {
                    if (!socket.isClosed()) {
                        socket.close();
                    }
                } catch (IOException ignored) {}
            }
        }

        private String handleRequest(String jsonRequest) {
            JsonObject response = new JsonObject();
            boolean needSaveData = false;

            try {
                JsonObject request = JsonParser.parseString(jsonRequest).getAsJsonObject();
                if (!request.has("action")) {
                    response.addProperty("statusCode", 400);
                    response.addProperty("message", "Action parameters missing.");
                    return gson.toJson(response);
                }

                String action = request.get("action").getAsString().trim();

                if (action.equalsIgnoreCase("signup")) {
                    String sUser = request.has("username") ? request.get("username").getAsString() : "";
                    String sPass = request.has("password") ? request.get("password").getAsString() : "";
                    return userService.registerUser(sUser, sPass, "", users);
                }
                else if (action.equalsIgnoreCase("login")) {
                    String lUser = request.has("username") ? request.get("username").getAsString() : "";
                    String lPass = request.has("password") ? request.get("password").getAsString() : "";
                    return userService.loginUser(lUser, lPass, users);
                }
                else if (action.equalsIgnoreCase("logout")) {
                    response.addProperty("statusCode", 200);
                    response.addProperty("message", "Logged out successfully.");
                }
                else if (action.equalsIgnoreCase("getAllImages")) {
                    JsonArray imgArray = new JsonArray();
                    synchronized (allImages) {
                        for (Image img : allImages) {
                            JsonObject imgObj = buildImageJsonObject(img);
                            imgArray.add(imgObj);
                        }
                    }
                    response.addProperty("statusCode", 200);
                    response.addProperty("message", "Images retrieved successfully.");
                    response.add("payload", imgArray);
                }
                else if (action.equalsIgnoreCase("getUserAlbums")) {
                    String userName = request.has("username") ? request.get("username").getAsString().trim() : "";
                    User u = null;
                    synchronized (users) {
                        u = users.stream()
                                .filter(usr -> usr.getUserName() != null && usr.getUserName().trim().equalsIgnoreCase(userName))
                                .findFirst()
                                .orElse(null);
                    }

                    if (u != null) {
                        JsonArray albumsArray = new JsonArray();
                        if (u.getAlbums() != null) {
                            for (Album alb : u.getAlbums()) {
                                JsonObject albObj = new JsonObject();
                                albObj.addProperty("title", alb.getName() != null ? alb.getName() : "");

                                JsonArray albImgs = new JsonArray();
                                if (alb.getImages() != null) {
                                    for (Image img : alb.getImages()) {
                                        albImgs.add(buildImageJsonObject(img));
                                    }
                                }
                                albObj.add("images", albImgs);
                                albumsArray.add(albObj);
                            }
                        }
                        response.addProperty("statusCode", 200);
                        response.addProperty("message", "User albums retrieved.");
                        response.add("payload", albumsArray);
                    } else {
                        response.addProperty("statusCode", 404);
                        response.addProperty("message", "User not found.");
                    }
                }
                else if (action.equalsIgnoreCase("uploadImage")) {
                    String imgName = request.has("title") ? request.get("title").getAsString().trim() :
                            (request.has("name") ? request.get("name").getAsString().trim() :
                                    (request.has("imageName") ? request.get("imageName").getAsString().trim() : ""));

                    String caption = request.has("caption") ? request.get("caption").getAsString().trim() : "";

                    String base64Data = request.has("imageData") ? request.get("imageData").getAsString() :
                            (request.has("base64Data") ? request.get("base64Data").getAsString() : "");

                    String uName = request.has("username") ? request.get("username").getAsString().trim() : "";

                    if (imgName.isEmpty() || base64Data.trim().isEmpty()) {
                        response.addProperty("statusCode", 400);
                        response.addProperty("message", "Image name/title or base64Data is missing.");
                    } else {
                        User u = null;
                        synchronized (users) {
                            u = users.stream()
                                    .filter(user -> user.getUserName() != null
                                            && user.getUserName().trim().equalsIgnoreCase(uName))
                                    .findFirst()
                                    .orElse(null);
                        }

                        if (u == null) {
                            response.addProperty("statusCode", 404);
                            response.addProperty("message", "User not found.");
                        } else {
                            String cleanBase64 = base64Data.contains(",") ? base64Data.split(",")[1] : base64Data;
                            String fileName = System.currentTimeMillis() + "_" + imgName.replaceAll("[^a-zA-Z0-9.-]", "_") + ".jpg";
                            String imgPath = PICS_DIR + fileName;

                            byte[] imageBytes = Base64.getDecoder().decode(cleanBase64.trim());
                            Files.write(Paths.get(imgPath), imageBytes);

                            String newId = String.valueOf(allImages.size() + 1);
                            Image image = new Image(newId, imgName, imgPath, u.getUserName(), LocalDate.now().toString());
                            image.setCaption(caption);

                            if (request.has("tags") && request.get("tags").isJsonArray()) {
                                JsonArray tagsArr = request.getAsJsonArray("tags");
                                for (JsonElement t : tagsArr) {
                                    imageService.addTag(image, t.getAsString());
                                }
                            }

                            imageService.uploadImage(u, image);
                            needSaveData = true;

                            JsonObject imgObj = buildImageJsonObject(image);

                            response.addProperty("statusCode", 200);
                            response.addProperty("message", "Image uploaded successfully.");
                            response.add("payload", imgObj);
                        }
                    }
                }
                else if (action.equalsIgnoreCase("deleteImage")) {
                    String delImgUser = request.has("username") ? request.get("username").getAsString().trim() : "";
                    String delImgName = request.has("name") ? request.get("name").getAsString().trim() :
                            (request.has("title") ? request.get("title").getAsString().trim() :
                                    (request.has("imageName") ? request.get("imageName").getAsString().trim() : ""));

                    User delUserObj = users.stream()
                            .filter(usr -> usr.getUserName() != null
                                    && usr.getUserName().trim().equalsIgnoreCase(delImgUser))
                            .findFirst()
                            .orElse(null);

                    if (delUserObj != null) {
                        Image imgToDelete = allImages.stream()
                                .filter(i -> i.getTitle() != null && i.getTitle().trim().equalsIgnoreCase(delImgName))
                                .findFirst()
                                .orElse(null);

                        if (imgToDelete != null) {
                            if (imgToDelete.getImagePath() != null) {
                                try {
                                    Files.deleteIfExists(Paths.get(imgToDelete.getImagePath()));
                                } catch (IOException ignored) {}
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
                            needSaveData = true;
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
                }
                else if (action.equalsIgnoreCase("likeImage") || action.equalsIgnoreCase("like") || action.equalsIgnoreCase("like_image") || action.equalsIgnoreCase("toggleLike")) {
                    String targetImgName = request.has("name") ? request.get("name").getAsString().trim() :
                            (request.has("title") ? request.get("title").getAsString().trim() :
                                    (request.has("imageName") ? request.get("imageName").getAsString().trim() : ""));

                    String likerUser = request.has("username") ? request.get("username").getAsString().trim() : "";

                    Image imgToLike = allImages.stream()
                            .filter(img -> img.getTitle() != null && img.getTitle().trim().equalsIgnoreCase(targetImgName))
                            .findFirst()
                            .orElse(null);

                    if (imgToLike != null) {
                        imageService.likeImage(imgToLike, likerUser);
                        needSaveData = true;
                        response.addProperty("statusCode", 200);
                        response.addProperty("message", "Like status updated.");
                    } else {
                        response.addProperty("statusCode", 404);
                        response.addProperty("message", "Image not found.");
                    }
                }
                else if (action.equalsIgnoreCase("addComment")) {
                    String cImgName = request.has("name") ? request.get("name").getAsString().trim() :
                            (request.has("title") ? request.get("title").getAsString().trim() :
                                    (request.has("imageName") ? request.get("imageName").getAsString().trim() : ""));
                    String commenter = request.has("username") ? request.get("username").getAsString().trim() : "";
                    String text = request.has("comment") ? request.get("comment").getAsString().trim()
                            : (request.has("text") ? request.get("text").getAsString().trim() : "");

                    Image imgToComment = allImages.stream()
                            .filter(img -> img.getTitle() != null && img.getTitle().trim().equalsIgnoreCase(cImgName))
                            .findFirst()
                            .orElse(null);

                    if (imgToComment != null) {
                        imageService.addComment(imgToComment, commenter, text);
                        needSaveData = true;
                        response.addProperty("statusCode", 200);
                        response.addProperty("message", "Comment added.");
                    } else {
                        response.addProperty("statusCode", 404);
                        response.addProperty("message", "Image not found.");
                    }
                }
                else if (action.equalsIgnoreCase("addTag")) {
                    String tagImgName = request.has("name") ? request.get("name").getAsString().trim() :
                            (request.has("title") ? request.get("title").getAsString().trim() :
                                    (request.has("imageName") ? request.get("imageName").getAsString().trim() : ""));
                    String tagText = request.has("tag") ? request.get("tag").getAsString().trim() : "";

                    Image imgToTag = allImages.stream()
                            .filter(img -> img.getTitle() != null && img.getTitle().trim().equalsIgnoreCase(tagImgName))
                            .findFirst()
                            .orElse(null);

                    if (imgToTag != null) {
                        imageService.addTag(imgToTag, tagText);
                        needSaveData = true;
                        response.addProperty("statusCode", 200);
                        response.addProperty("message", "Tag added successfully.");
                    } else {
                        response.addProperty("statusCode", 404);
                        response.addProperty("message", "Image not found.");
                    }
                }
                else if (action.equalsIgnoreCase("createAlbum")) {
                    String albUser = request.has("username") ? request.get("username").getAsString().trim() : "";
                    String albTitle = request.has("title") ? request.get("title").getAsString().trim() : "";
                    User owner = users.stream()
                            .filter(usr -> usr.getUserName() != null
                                    && usr.getUserName().trim().equalsIgnoreCase(albUser))
                            .findFirst()
                            .orElse(null);
                    if (owner != null) {
                        Album newAlbum = albumService.createAlbum(owner, albTitle);
                        if (newAlbum != null) {
                            needSaveData = true;
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
                }
                else if (action.equalsIgnoreCase("deleteAlbum")) {
                    String delUser = request.has("username") ? request.get("username").getAsString().trim() : "";
                    String delTitle = request.has("title") ? request.get("title").getAsString().trim() : "";
                    User dOwner = users.stream()
                            .filter(usr -> usr.getUserName() != null
                                    && usr.getUserName().trim().equalsIgnoreCase(delUser))
                            .findFirst()
                            .orElse(null);
                    if (dOwner != null) {
                        Album targetAlbum = dOwner.getAlbums().stream()
                                .filter(a -> a.getName() != null && a.getName().trim().equalsIgnoreCase(delTitle))
                                .findFirst()
                                .orElse(null);
                        if (targetAlbum != null) {
                            albumService.deleteAlbum(dOwner, targetAlbum);
                            needSaveData = true;
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
                }
                else if (action.equalsIgnoreCase("removeImageFromAlbum")) {
                    String remUser = request.has("username") ? request.get("username").getAsString().trim() : "";
                    String remTitle = request.has("title") ? request.get("title").getAsString().trim() : "";
                    String remImgName = request.has("name") ? request.get("name").getAsString().trim() :
                            (request.has("imageName") ? request.get("imageName").getAsString().trim() : "");
                    User remOwner = users.stream()
                            .filter(usr -> usr.getUserName() != null
                                    && usr.getUserName().trim().equalsIgnoreCase(remUser))
                            .findFirst()
                            .orElse(null);
                    if (remOwner != null) {
                        Album remAlb = remOwner.getAlbums().stream()
                                .filter(a -> a.getName() != null && a.getName().trim().equalsIgnoreCase(remTitle))
                                .findFirst()
                                .orElse(null);
                        if (remAlb != null) {
                            remAlb.getImages()
                                    .removeIf(i -> i.getTitle() != null && i.getTitle().trim().equalsIgnoreCase(remImgName));
                            needSaveData = true;
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
                }
                else if (action.equalsIgnoreCase("moveImage")) {
                    String mUser = request.has("username") ? request.get("username").getAsString().trim() : "";
                    String srcTitle = request.has("sourceAlbum") ? request.get("sourceAlbum").getAsString().trim() : "";
                    String destTitle = request.has("targetAlbum") ? request.get("targetAlbum").getAsString().trim() : "";
                    String targetImg = request.has("imageName") ? request.get("imageName").getAsString().trim() :
                            (request.has("name") ? request.get("name").getAsString().trim() : "");
                    User mOwner = users.stream()
                            .filter(usr -> usr.getUserName() != null
                                    && usr.getUserName().trim().equalsIgnoreCase(mUser))
                            .findFirst()
                            .orElse(null);
                    if (mOwner != null) {
                        Album srcAlb = mOwner.getAlbums().stream()
                                .filter(a -> a.getName() != null && a.getName().trim().equalsIgnoreCase(srcTitle))
                                .findFirst().orElse(null);
                        Album destAlb = mOwner.getAlbums().stream()
                                .filter(a -> a.getName() != null && a.getName().trim().equalsIgnoreCase(destTitle))
                                .findFirst().orElse(null);
                        Image target = allImages.stream()
                                .filter(i -> i.getTitle() != null && i.getTitle().trim().equalsIgnoreCase(targetImg)).findFirst()
                                .orElse(null);
                        if (srcAlb != null && destAlb != null && target != null) {
                            boolean moved = albumService.moveImageOtherAlbum(srcAlb, destAlb, target);
                            if (moved) {
                                needSaveData = true;
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
                }
                else {
                    response.addProperty("statusCode", 400);
                    response.addProperty("message", "Unknown action");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.addProperty("statusCode", 500);
                response.addProperty("message", "Internal server error: " + e.getMessage());
            }

            if (needSaveData) {
                DatabaseManager.saveData(users, allImages);
            }
            return gson.toJson(response);
        }

        private JsonObject buildImageJsonObject(Image img) {
            JsonObject imgObj = new JsonObject();
            imgObj.addProperty("name", img.getTitle() != null ? img.getTitle() : "");
            imgObj.addProperty("caption", img.getCaption() != null ? img.getCaption() : "");

            String base64Content = "";
            if (img.getImagePath() != null) {
                try {
                    File imgFile = new File(img.getImagePath());
                    if (imgFile.exists()) {
                        byte[] fileBytes = Files.readAllBytes(imgFile.toPath());
                        base64Content = Base64.getEncoder().encodeToString(fileBytes);
                    }
                } catch (IOException e) {
                    base64Content = "";
                }
            }

            imgObj.addProperty("imageUrl", base64Content);
            imgObj.addProperty("likes", img.getLikes() != null ? img.getLikes().size() : 0);

            JsonArray likedUsersArray = new JsonArray();
            if (img.getLikes() != null) {
                for (String liker : img.getLikes()) {
                    likedUsersArray.add(liker);
                }
            }
            imgObj.add("likedUsernames", likedUsersArray);
            imgObj.add("likedByUsers", likedUsersArray);

            JsonArray tagsArray = new JsonArray();
            if (img.getTags() != null) {
                for (String tag : img.getTags()) {
                    tagsArray.add(tag);
                }
            }
            imgObj.add("tags", tagsArray);

            JsonArray commentsArray = new JsonArray();
            if (img.getComments() != null) {
                for (Comment c : img.getComments()) {
                    JsonObject cObj = new JsonObject();
                    cObj.addProperty("username", c.getUserName() != null ? c.getUserName() : "");
                    cObj.addProperty("text", c.getText() != null ? c.getText() : "");
                    commentsArray.add(cObj);
                }
            }
            imgObj.add("comments", commentsArray);

            return imgObj;
        }
    }
}