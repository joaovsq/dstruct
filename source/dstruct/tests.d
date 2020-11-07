/**
 * HibernateD - Object-Relation Mapping for D programming language, with interface similar to Hibernate. 
 * 
 * Hibernate documentation can be found here:
 * $(LINK http://hibernate.org/docs)$(BR)
 * 
 * Source file hibernated/tests.d.
 *
 * This module contains unit tests for functional testing on real DB.
 * 
 * Copyright: Copyright 2013
 * License:   $(LINK www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Author:   Vadim Lopatin
 */
module dstruct.tests;

import std.algorithm;
import std.conv;
import std.stdio;
import std.datetime;
import std.typecons;
import std.exception;
import std.variant;

import dstruct.core;

version (unittest)
{

    //@Entity
    @Table("users")  // to override table name - "users" instead of default "user"
    class User
    {

        //@Generated
        long id;

        string name;

        // property column
        private long _flags;
        @Null // override NotNull which is inferred from long type
        @property void flags(long v)
        {
            _flags = v;
        }

        @property ref long flags()
        {
            return _flags;
        }

        // getter/setter property
        string comment;
        // @Column -- not mandatory, will be deduced
        @Null // override default nullability of string with @Null (instead of using String)
        @Column(null, 1024)  // override default length, autogenerate column name)
        string getComment()
        {
            return comment;
        }

        void setComment(string v)
        {
            comment = v;
        }

        //@ManyToOne -- not mandatory, will be deduced
        //@JoinColumn("customer_fk")
        Customer customer;

        @ManyToMany LazyCollection!Role roles;

        override string toString()
        {
            return "id=" ~ to!string(id) ~ ", name=" ~ name ~ ", flags=" ~ to!string(
                    flags) ~ ", comment=" ~ comment ~ ", customerId=" ~ (customer is null
                    ? "NULL" : customer.toString());
        }

    }

    //@Entity
    @Table("customers")  // to override table name - "customers" instead of default "customer"
    class Customer
    {
        //@Generated
        int id;
        // @Column -- not mandatory, will be deduced
        string name;

        // deduced as @Embedded automatically
        Address address;

        //@ManyToOne -- not mandatory, will be deduced
        //@JoinColumn("account_type_fk")
        Lazy!AccountType accountType;

        //        @OneToMany("customer")
        //        LazyCollection!User users;

        //@OneToMany("customer") -- not mandatory, will be deduced
        private User[] _users;
        @property User[] users()
        {
            return _users;
        }

        @property void users(User[] value)
        {
            _users = value;
        }

        this()
        {
            address = new Address();
        }

        override string toString()
        {
            return "id=" ~ to!string(id) ~ ", name=" ~ name ~ ", address=" ~ address.toString();
        }
    }

    static assert(isEmbeddedObjectMember!(Customer, "address"));

    @Embeddable class Address
    {
        String zip;
        String city;
        String streetAddress;
        @Transient // mark field with @Transient to avoid creating column for it
        string someNonPersistentField;

        override string toString()
        {
            return " zip=" ~ zip ~ ", city=" ~ city ~ ", streetAddress=" ~ streetAddress;
        }
    }

    @Entity // need to have at least one annotation to import automatically from module
    class AccountType
    {
        //@Generated
        int id;
        string name;
    }

    //@Entity 
    class Role
    {
        //@Generated
        int id;
        string name;
        @ManyToMany LazyCollection!User users;
    }

    //@Entity
    //@Table("t1")
    class T1
    {
        //@Id 
        //@Generated
        int id;

        //@NotNull 
        @UniqueKey string name;

        // property column
        private long _flags;
        // @Column -- not mandatory, will be deduced
        @property long flags()
        {
            return _flags;
        }

        @property void flags(long v)
        {
            _flags = v;
        }

        // getter/setter property
        private string comment;
        // @Column -- not mandatory, will be deduced
        @Null string getComment()
        {
            return comment;
        }

        void setComment(string v)
        {
            comment = v;
        }

        override string toString()
        {
            return "id=" ~ to!string(id) ~ ", name=" ~ name ~ ", flags=" ~ to!string(
                    flags) ~ ", comment=" ~ comment;
        }
    }

    @Entity static class GeneratorTest
    {
        //@Generator("std.uuid.randomUUID().toString()")
        @Generator(UUID_GENERATOR)
        string id;
        string name;
    }

    @Entity static class TypeTest
    {
        //@Generated
        int id;
        string string_field;
        String nullable_string_field;
        byte byte_field;
        short short_field;
        int int_field;
        long long_field;
        ubyte ubyte_field;
        ushort ushort_field;
        ulong ulong_field;
        DateTime datetime_field;
        Date date_field;
        TimeOfDay time_field;
        Byte nullable_byte_field;
        Short nullable_short_field;
        Int nullable_int_field;
        Long nullable_long_field;
        Ubyte nullable_ubyte_field;
        Ushort nullable_ushort_field;
        Ulong nullable_ulong_field;
        NullableDateTime nullable_datetime_field;
        NullableDate nullable_date_field;
        NullableTimeOfDay nullable_time_field;
        float float_field;
        double double_field;
        Float nullable_float_field;
        Double nullable_double_field;
        byte[] byte_array_field;
        ubyte[] ubyte_array_field;
    }

}

// unittest
// {
//     if (DB_TESTS_ENABLED)
//     {
//         recreateTestSchema(true, false, false);

//         //writeln("metadata test 2");

//         // Checking generated metadata
//         EntityMetaData schema = new SchemaInfoImpl!(User, Customer, AccountType, T1,
//                 TypeTest, Address, Role, GeneratorTest, Person, MoreInfo, EvenMoreInfo);
//         Dialect dialect = getUnitTestDialect();

//         DBInfo db = new DBInfo(dialect, schema);
//         string[] createTables = db.getCreateTableSQL();
//         //        foreach(t; createTables)
//         //            writeln(t);
//         string[] createIndexes = db.getCreateIndexSQL();
//         //        foreach(t; createIndexes)
//         //            writeln(t);
//         static if (SQLITE_TESTS_ENABLED)
//         {
//             assert(db["users"].getCreateTableSQL() == "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, flags INT NULL, comment TEXT NULL, customer_fk INT NULL)");
//             assert(db["customers"].getCreateTableSQL() == "CREATE TABLE customers (id INTEGER PRIMARY KEY, name TEXT NOT NULL, zip TEXT NULL, city TEXT NULL, street_address TEXT NULL, account_type_fk INT NULL)");
//             assert(db["account_type"].getCreateTableSQL() == "CREATE TABLE account_type (id INTEGER PRIMARY KEY, name TEXT NOT NULL)");
//             assert(db["t1"].getCreateTableSQL()
//                     == "CREATE TABLE t1 (id INTEGER PRIMARY KEY, name TEXT NOT NULL, flags INT NOT NULL, comment TEXT NULL)");
//             assert(db["role"].getCreateTableSQL() == "CREATE TABLE role (id INTEGER PRIMARY KEY, name TEXT NOT NULL)");
//             assert(db["generator_test"].getCreateTableSQL() == "CREATE TABLE generator_test (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL)");
//             assert(db["role_users"].getCreateTableSQL() == "CREATE TABLE role_users (role_fk INT NOT NULL, user_fk INT NOT NULL, PRIMARY KEY (role_fk, user_fk), UNIQUE (user_fk, role_fk))");
//         }
//         else static if (PGSQL_TESTS_ENABLED)
//         {
//         }

//         DataSource ds = getUnitTestDataSource();
//         if (ds is null)
//             return; // DB tests disabled
//         SessionFactory factory = new SessionFactoryImpl(schema, dialect, ds);
//         db = factory.getDBMetaData();
//         {
//             Connection conn = ds.getConnection();
//             scope (exit)
//                 conn.close();
//             db.updateDBSchema(conn, true, true);
//             recreateTestSchema(false, false, true);
//         }

//         scope (exit)
//             factory.close();
//         {
//             Session sess = factory.openSession();
//             scope (exit)
//                 sess.close();

//             User u1 = sess.load!User(1);
//             //writeln("Loaded value: " ~ u1.toString);
//             assert(u1.id == 1);
//             assert(u1.name == "user 1");
//             assert(u1.customer.name == "customer 1");
//             assert(u1.customer.accountType() !is null);
//             assert(u1.customer.accountType().name == "Type1");
//             Role[] u1roles = u1.roles;
//             assert(u1roles.length == 2);

//             User u2 = sess.load!User(2);
//             assert(u2.name == "user 2");
//             assert(u2.flags == 22); // NULL is loaded as 0 if property cannot hold nulls

//             User u3 = sess.get!User(3);
//             assert(u3.name == "user 3");
//             assert(u3.flags == 0); // NULL is loaded as 0 if property cannot hold nulls
//             assert(u3.getComment() !is null);
//             assert(u3.customer.name == "customer 2");
//             assert(u3.customer.accountType() is null);

//             User u4 = new User();
//             sess.load(u4, 4);
//             assert(u4.name == "user 4");
//             assert(u4.getComment() is null);

//             User u5 = new User();
//             u5.id = 5;
//             sess.refresh(u5);
//             assert(u5.name == "test user 5");
//             //assert(u5.customer !is null);

//             u5 = sess.load!User(5);
//             assert(u5.name == "test user 5");
//             assert(u5.customer !is null);
//             assert(u5.customer.id == 3);
//             assert(u5.customer.name == "customer 3");
//             assert(u5.customer.accountType() !is null);
//             assert(u5.customer.accountType().name == "Type2");

//             User u6 = sess.load!User(6);
//             assert(u6.name == "test user 6");
//             assert(u6.customer is null);

//             // 
//             //writeln("loading customer 3");
//             // testing @Embedded property
//             Customer c3 = sess.load!Customer(3);
//             assert(c3.address.zip is null);
//             assert(c3.address.streetAddress == "Baker Street, 24");
//             c3.address.streetAddress = "Baker Street, 24/2";
//             c3.address.zip = "55555";

//             User[] c3users = c3.users;
//             //writeln("        ***      customer has " ~ to!string(c3users.length) ~ " users");
//             assert(c3users.length == 2);
//             assert(c3users[0].customer == c3);
//             assert(c3users[1].customer == c3);

//             //writeln("updating customer 3");
//             sess.update(c3);
//             Customer c3_reloaded = sess.load!Customer(3);
//             assert(c3.address.streetAddress == "Baker Street, 24/2");
//             assert(c3.address.zip == "55555");

//         }
//         {
//             Session sess = factory.openSession();
//             scope (exit)
//                 sess.close();

//             // check Session.save() when id is filled
//             Customer c4 = new Customer();
//             c4.id = 4;
//             c4.name = "Customer_4";
//             sess.save(c4);

//             Customer c4_check = sess.load!Customer(4);
//             assert(c4.id == c4_check.id);
//             assert(c4.name == c4_check.name);

//             sess.remove(c4);

//             c4 = sess.get!Customer(4);
//             assert(c4 is null);

//             Customer c5 = new Customer();
//             c5.name = "Customer_5";
//             sess.save(c5);

//             // Testing generator function (uuid)
//             GeneratorTest g1 = new GeneratorTest();
//             g1.name = "row 1";
//             assert(g1.id is null);
//             sess.save(g1);
//             assert(g1.id !is null);

//             assertThrown!MappingException(
//                     sess.createQuery("SELECT id, name, blabla FROM User ORDER BY name"));
//             assertThrown!QuerySyntaxException(
//                     sess.createQuery("SELECT id: name FROM User ORDER BY name"));

//             // test multiple row query
//             Query q = sess.createQuery("FROM User ORDER BY name");
//             User[] list = q.list!User();
//             assert(list.length == 6);
//             assert(list[0].name == "test user 5");
//             assert(list[1].name == "test user 6");
//             assert(list[2].name == "user 1");
//             //      writeln("Read " ~ to!string(list.length) ~ " rows from User");
//             //      foreach(row; list) {
//             //          writeln(row.toString());
//             //      }
//             Variant[][] rows = q.listRows();
//             assert(rows.length == 6);
//             //      foreach(row; rows) {
//             //          writeln(row);
//             //      }
//             assertThrown!HibernatedException(q.uniqueResult!User());
//             assertThrown!HibernatedException(q.uniqueRow());

//         }
//         {
//             Session sess = factory.openSession();
//             scope (exit)
//                 sess.close();

//             // test single row select
//             Query q = sess.createQuery(
//                     "FROM User AS u WHERE id = :Id and (u.name like '%test%' or flags=44)");
//             assertThrown!HibernatedException(q.list!User()); // cannot execute w/o all parameters set
//             q.setParameter("Id", Variant(6));
//             User[] list = q.list!User();
//             assert(list.length == 1);
//             assert(list[0].name == "test user 6");
//             //      writeln("Read " ~ to!string(list.length) ~ " rows from User");
//             //      foreach(row; list) {
//             //          writeln(row.toString());
//             //      }
//             User uu = q.uniqueResult!User();
//             assert(uu.name == "test user 6");
//             Variant[] row = q.uniqueRow();
//             assert(row[0] == 6L);
//             assert(row[1] == "test user 6");

//             // test empty SELECT result
//             q.setParameter("Id", Variant(7));
//             row = q.uniqueRow();
//             assert(row is null);
//             uu = q.uniqueResult!User();
//             assert(uu is null);

//             q = sess.createQuery("SELECT c.name, c.address.zip FROM Customer AS c WHERE id = :Id")
//                 .setParameter("Id", Variant(1));
//             row = q.uniqueRow();
//             assert(row !is null);
//             assert(row[0] == "customer 1"); // name
//             assert(row[1] == "12345"); // address.zip

//         }
//         {
//             // prepare data
//             Session sess = factory.openSession();
//             scope (exit)
//                 sess.close();

//             Role r10 = new Role();
//             r10.name = "role10";
//             Role r11 = new Role();
//             r11.name = "role11";
//             Customer c10 = new Customer();
//             c10.name = "Customer 10";
//             User u10 = new User();
//             u10.name = "Alex";
//             u10.customer = c10;
//             u10.roles = [r10, r11];
//             sess.save(r10);
//             sess.save(r11);
//             sess.save(c10);
//             sess.save(u10);
//             assert(c10.id != 0);
//             assert(u10.id != 0);
//             assert(r10.id != 0);
//             assert(r11.id != 0);
//         }
//         {
//             // check data in separate session
//             Session sess = factory.openSession();
//             scope (exit)
//                 sess.close();
//             User u10 = sess.createQuery("FROM User WHERE name=:Name")
//                 .setParameter("Name", "Alex").uniqueResult!User();
//             assert(u10.roles.length == 2);
//             assert(u10.roles[0].name == "role10" || u10.roles.get()[0].name == "role11");
//             assert(u10.roles[1].name == "role10" || u10.roles.get()[1].name == "role11");
//             assert(u10.customer.name == "Customer 10");
//             assert(u10.customer.users.length == 1);
//             assert(u10.customer.users[0] == u10);
//             assert(u10.roles[0].users.length == 1);
//             assert(u10.roles[0].users[0] == u10);
//             // removing one role from user
//             u10.roles.get().remove(0);
//             sess.update(u10);
//         }
//         {
//             // check that only one role left
//             Session sess = factory.openSession();
//             scope (exit)
//                 sess.close();
//             User u10 = sess.createQuery("FROM User WHERE name=:Name")
//                 .setParameter("Name", "Alex").uniqueResult!User();
//             assert(u10.roles.length == 1);
//             assert(u10.roles[0].name == "role10" || u10.roles.get()[0].name == "role11");
//             // remove user
//             sess.remove(u10);
//         }
//         {
//             // check that user is removed
//             Session sess = factory.openSession();
//             scope (exit)
//                 sess.close();
//             User u10 = sess.createQuery("FROM User WHERE name=:Name")
//                 .setParameter("Name", "Alex").uniqueResult!User();
//             assert(u10 is null);
//         }
//     }
// }

version (unittest)
{
    // for testing of Embeddable
    @Embeddable class EMName
    {
        string firstName;
        string lastName;
    }

    //@Entity 
    class EMUser
    {
        //@Id @Generated
        //@Column
        int id;

        // deduced as @Embedded automatically
        EMName userName;
    }

    // for testing of Embeddable
    //@Entity
    class Person
    {
        //@Id
        int id;

        // @Column @NotNull        
        string firstName;
        // @Column @NotNull        
        string lastName;

        @NotNull @OneToOne @JoinColumn("more_info_fk")
        MoreInfo moreInfo;
    }

    //@Entity
    @Table("person_info")
    class MoreInfo
    {
        //@Id @Generated
        int id;
        // @Column 
        long flags;
        @OneToOne("moreInfo")
        Person person;
        @OneToOne("personInfo")
        EvenMoreInfo evenMore;
    }

    //@Entity
    @Table("person_info2")
    class EvenMoreInfo
    {
        //@Id @Generated
        int id;
        //@Column 
        long flags;
        @OneToOne @JoinColumn("person_info_fk")
        MoreInfo personInfo;
    }

}

