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
