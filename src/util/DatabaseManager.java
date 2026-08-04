package util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import model.Image;
import model.User;

import java.io.*;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class DatabaseManager {
    private static final String USERS_FILE = "UsersDatabase.json";
    private static final String IMAGES_FILE = "ImagesDatabase.json";
    private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    public static synchronized void saveData(List<User> users, List<Image> allImages) {
        try {
            try (Writer writer = new OutputStreamWriter(new FileOutputStream(USERS_FILE), StandardCharsets.UTF_8)) {
                gson.toJson(users != null ? users : new ArrayList<>(), writer);
            }

            try (Writer writer = new OutputStreamWriter(new FileOutputStream(IMAGES_FILE), StandardCharsets.UTF_8)) {
                gson.toJson(allImages != null ? allImages : new ArrayList<>(), writer);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static synchronized List<User> loadUsers() {
        File file = new File(USERS_FILE);
        if (!file.exists() || file.length() == 0) {
            return new ArrayList<>();
        }

        try (Reader reader = new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8)) {
            Type userListType = new TypeToken<ArrayList<User>>() {}.getType();
            List<User> loadedUsers = gson.fromJson(reader, userListType);
            return loadedUsers != null ? loadedUsers : new ArrayList<>();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static synchronized List<Image> loadImages() {
        File file = new File(IMAGES_FILE);
        if (!file.exists() || file.length() == 0) {
            return new ArrayList<>();
        }

        try (Reader reader = new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8)) {
            Type imageListType = new TypeToken<ArrayList<Image>>() {}.getType();
            List<Image> loadedImages = gson.fromJson(reader, imageListType);
            return loadedImages != null ? loadedImages : new ArrayList<>();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}