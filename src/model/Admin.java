package model;

public class Admin extends User {

    public Admin() {
        super();
        this.setAdmin(true);
    }

    public Admin(String userName, String password) {
        super(userName, password);
        this.setAdmin(true);
    }

    public Admin(String id, String userName, String password, String email) {
        super(id, userName, password, email);
        this.setAdmin(true);
    }
}