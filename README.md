Warnings
--------------------

* DStruct is deeply in development mode, so breaking changes will happen.

* For now, DStruct is only supported on Linux, but Windows support can easily be added in the future (unfortunately, i don't have the time right now).

DStruct | ![master](https://github.com/joaovsq/DStruct/workflows/Default/badge.svg?branch=master)
==========

A simple ORM for D language.

This project started as a fork of https://github.com/buggins/dstruct created by Vadim Lopatin.

All credits to the original author will be maintained.

Install
--------------------

``` dub add dstruct-orm ```

Supported databases
--------------------

* PostgreSQL
* SQLite

Why create a fork ?
--------------------

I needed some quick bugfixes and additional features for my personal projects, i also made some different design decisions. This fork is also more self-contained and mostly Posgres focused. So i thought this could be useful to more people.

All credits to the original author will be maintained in the source code and README. The library renaming is just to avoid possible confusions. The license is the same.

Requirements
--------------------

Ubuntu 18.04

* libpq-dev
* libsqlite3-dev

Windows 

* TODO 

Libraries
--------------------

Open source libraries used by DStruct. Some may have been modified to suit the project needs.

* ddbc - https://github.com/buggins/ddbc
* derelictPQ - https://github.com/DerelictOrg/DerelictPQ
* derelictUtils - https://github.com/DerelictOrg/DerelictUtil

Sample code:
--------------------

```D
import dstruct.core;
import std.algorithm;


// Annotations of entity classes

class User {
    long id;
    string name;
    Customer customer;
    @ManyToMany // cannot be inferred, requires annotation
        LazyCollection!Role roles;
}

class Customer {
    int id;
    string name;
    // Embedded is inferred from type of Address
    Address address;

    Lazy!AccountType accountType; // ManyToOne inferred

    User[] users; // OneToMany inferred

    this() {
        address = new Address();
    }
}

@Embeddable
class Address {
    string zip;
    string city;
    string streetAddress;
}

class AccountType {
    int id;
    string name;
}

class Role {
    int id;
    string name;
    @ManyToMany // w/o this annotation will be OneToMany by convention
        LazyCollection!User users;
}

int main() {

    // create metadata from annotations
    EntityMetaData schema = new SchemaInfoImpl!(User, Customer, AccountType, 
            Address, Role);




    // setup DB connection factory
    version (USE_MYSQL) {
        import dstruct.ddbc.drivers.mysqlddbc;
        MySQLDriver driver = new MySQLDriver();
        string url = MySQLDriver.generateUrl("localhost", 3306, "test_db");
        string[string] params = MySQLDriver.setUserAndPassword("testuser", "testpasswd");
        Dialect dialect = new MySQLDialect();
    } else {
        import dstruct.ddbc.drivers.sqliteddbc;
        SQLITEDriver driver = new SQLITEDriver();
        string url = "zzz.db"; // file with DB
        static import std.file;
        if (std.file.exists(url))
            std.file.remove(url); // remove old DB file
        string[string] params;
        Dialect dialect = new SQLiteDialect();
    }
    DataSource ds = new ConnectionPoolDataSourceImpl(driver, url, params);


    // create session factory
    SessionFactory factory = new SessionFactoryImpl(schema, dialect, ds);
    scope(exit) factory.close();

    // Create schema if necessary
    {
        // get connection
        Connection conn = ds.getConnection();
        scope(exit) conn.close();
        // create tables if not exist
        factory.getDBMetaData().updateDBSchema(conn, false, true);
    }

    // Now you can use DStruct

    // create session
    Session sess = factory.openSession();
    scope(exit) sess.close();

    // use session to access DB

    // read all users using query
    Query q = sess.createQuery("FROM User ORDER BY name");
    User[] list = q.list!User();

    // create sample data
    Role r10 = new Role();
    r10.name = "role10";
    Role r11 = new Role();
    r11.name = "role11";
    Customer c10 = new Customer();
    c10.name = "Customer 10";
    c10.address = new Address();
    c10.address.zip = "12345";
    c10.address.city = "New York";
    c10.address.streetAddress = "Baker st., 12";
    User u10 = new User();
    u10.name = "Alex";
    u10.customer = c10;
    u10.roles = [r10, r11];
    sess.save(r10);
    sess.save(r11);
    sess.save(c10);
    sess.save(u10);

    // load and check data
    User u11 = sess.createQuery("FROM User WHERE name=:Name").
        setParameter("Name", "Alex").uniqueResult!User();
    assert(u11.roles.length == 2);
    assert(u11.roles[0].name == "role10" || u11.roles.get()[0].name == "role11");
    assert(u11.roles[1].name == "role10" || u11.roles.get()[1].name == "role11");
    assert(u11.customer.name == "Customer 10");
    assert(u11.customer.users.length == 1);
    assert(u11.customer.users[0] == u10);
    assert(u11.roles[0].users.length == 1);
    assert(u11.roles[0].users[0] == u10);

    // remove reference
    u11.roles = u11.roles().remove(0);
    sess.update(u11);

    // remove entity
    sess.remove(u11);
    return 0;
}
```

About the codebase
--------------------

* Follow D style conventions (https://dlang.org/dstyle.html).
* C/C++ bindings should be in the source code and not as separated dub packages.
