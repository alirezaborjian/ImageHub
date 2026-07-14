package service;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import model.*;
import util.DatabaseManager;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class APIServer {
    private static final int PORT = 8080;
    private static List<User> users;
    private static List<Image> allImages;
    private static Set<User> bannedUsers;

    private static UserService userService;
    private static ImageService imageService;
    private static AlbumService albumService;
    private static final Gson gson = new Gson();
    private static final String PICS_DIR = "pictures/";

    public static void main(String[] args) {
        users = DatabaseManager.loadUsers();
        allImages = DatabaseManager.loadImages();
        bannedUsers = new HashSet<>();
        
        for (User u : users) {
            if (u.isBanned()) bannedUsers.add(u);
        }

        userService = new UserService(users);
        imageService = new ImageService(allImages);
        albumService = new AlbumService(allImages);

        try {
            Files.createDirectories(Paths.get(PICS_DIR));
        } catch (IOException e) {
            e.printStackTrace();
        }

        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            while (true) {
                Socket clientSocket = serverSocket.accept();
                new Thread(new ClientHandler(clientSocket)).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static class ClientHandler implements Runnable {
        private Socket socket;

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
                String action = request.get("action").getAsString();

                switch (action) {
                    case "signup":
                        String sUser = request.get("username").getAsString();
                        String sPass = request.get("password").getAsString();
                        User newUser = new User(sUser, sPass);
                        userService.signup(newUser);
                        response.addProperty("status", "success");
                        break;

                    case "login":
                        String lUser = request.get("username").getAsString();
                        String lPass = request.get("password").getAsString();
                        User loggedInUser = userService.login(lUser, lPass);
                        response.addProperty("status", "success");
                        response.addProperty("username", loggedInUser.getUserName());
                        break;

                    case "logout":
                        response.addProperty("status", "success");
                        break;

                    case "uploadImage":
                        String imgName = request.get("name").getAsString();
                        String caption = request.get("caption").getAsString();
                        String base64Data = request.get("base64Data").getAsString();
                        String uName = request.has("username") ? request.get("username").getAsString() : "";

                        byte[] imageBytes = Base64.getDecoder().decode(base64Data);
                        Files.write(Paths.get(PICS_DIR + imgName + ".jpg"), imageBytes);

                        Image image = new Image(imgName, caption);
                        User u = users.stream()
                                .filter(user -> user.getUserName().equalsIgnoreCase(uName))
                                .findFirst()
                                .orElse(users.isEmpty() ? null : users.get(0));

                        imageService.uploadImage(u, image);

                        JsonObject imgObj = new JsonObject();
                        imgObj.addProperty("name", image.getName());
                        imgObj.addProperty("caption", image.getCaption());
                        response.add("image", imgObj);
                        response.addProperty("status", "success");
                        break;

                    case "likeImage":
                        String targetImgName = request.get("name").getAsString();
                        allImages.stream()
                                .filter(img -> img.getName().equals(targetImgName))
                                .findFirst()
                                .ifPresent(imageService::likeImage);
                        response.addProperty("status", "success");
                        break;

                    case "addComment":
                        String cImgName = request.get("name").getAsString();
                        String commenter = request.get("username").getAsString();
                        String text = request.get("text").getAsString();
                        allImages.stream()
                                .filter(img -> img.getName().equals(cImgName))
                                .findFirst()
                                .ifPresent(img -> imageService.addComment(img, commenter, text));
                        response.addProperty("status", "success");
                        break;

                    case "createAlbum":
                        String albUser = request.get("username").getAsString();
                        String albTitle = request.get("title").getAsString();
                        User owner = users.stream()
                                .filter(usr -> usr.getUserName().equalsIgnoreCase(albUser))
                                .findFirst()
                                .orElse(null);
                        if (owner != null) {
                            Album newAlbum = albumService.createAlbum(owner, albTitle);
                            if (newAlbum != null) {
                                response.addProperty("status", "success");
                            } else {
                                response.addProperty("status", "error");
                                response.addProperty("message", "Album already exists.");
                            }
                        } else {
                            response.addProperty("status", "error");
                        }
                        break;

                    case "deleteAlbum":
                        String delUser = request.get("username").getAsString();
                        String delTitle = request.get("title").getAsString();
                        User dOwner = users.stream()
                                .filter(usr -> usr.getUserName().equalsIgnoreCase(delUser))
                                .findFirst()
                                .orElse(null);
                        if (dOwner != null) {
                            Album targetAlbum = dOwner.getAlbums().stream()
                                    .filter(a -> a.getTitle().equalsIgnoreCase(delTitle))
                                    .findFirst()
                                    .orElse(null);
                            if (targetAlbum != null) {
                                albumService.deleteAlbum(dOwner, targetAlbum);
                                response.addProperty("status", "success");
                            } else {
                                response.addProperty("status", "error");
                            }
                        } else {
                            response.addProperty("status", "error");
                        }
                        break;

                    case "moveImage":
                        String mUser = request.get("username").getAsString();
                        String srcTitle = request.get("sourceAlbum").getAsString();
                        String destTitle = request.get("targetAlbum").getAsString();
                        String targetImg = request.get("imageName").getAsString();
                        User mOwner = users.stream()
                                .filter(usr -> usr.getUserName().equalsIgnoreCase(mUser))
                                .findFirst()
                                .orElse(null);
                        if (mOwner != null) {
                            Album srcAlb = mOwner.getAlbums().stream().filter(a -> a.getTitle().equalsIgnoreCase(srcTitle)).findFirst().orElse(null);
                            Album destAlb = mOwner.getAlbums().stream().filter(a -> a.getTitle().equalsIgnoreCase(destTitle)).findFirst().orElse(null);
                            Image target = allImages.stream().filter(i -> i.getName().equals(targetImg)).findFirst().orElse(null);
                            if (srcAlb != null && destAlb != null && target != null) {
                                boolean moved = albumService.moveImageOtherAlbum(srcAlb, destAlb, target);
                                response.addProperty("status", moved ? "success" : "error");
                            } else {
                                response.addProperty("status", "error");
                            }
                        } else {
                            response.addProperty("status", "error");
                        }
                        break;

                    default:
                        response.addProperty("status", "error");
                }
            } catch (Exception e) {
                response.addProperty("status", "error");
                response.addProperty("message", e.getMessage());
            }
            DatabaseManager.saveData(users, allImages);
            return gson.toJson(response);
        }
    }
}