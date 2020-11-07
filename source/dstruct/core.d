/**
 * DStruct - Object-Relation Mapping for D programming language, with interface similar to Hibernate. 
 * 
 * Hibernate documentation can be found here:
 * $(LINK http://hibernate.org/docs)$(BR)
 * 
 * Source file dstruct/core.d.
 *
 * This module is convinient way to import all declarations to use dstruct
 * 
 * Copyright: Copyright 2013
 * License:   $(LINK www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Author:   Vadim Lopatin
 */
module dstruct.core;

//public import std.ascii;
//public import std.conv;
//public import std.datetime;
//public import std.exception;
//public import std.stdio;

//public import std.string;
//public import std.traits;
//public import std.typecons;
//public import std.typetuple;
//public import std.variant;

public import dstruct.ddbc;

public import dstruct.annotations;
public import dstruct.session;
public import dstruct.metadata;
public import dstruct.core;
public import dstruct.type;
public import dstruct.dialect;

version( USE_SQLITE )
{
    public import dstruct.dialects.sqlitedialect;
}
version( USE_PGSQL )
{
    public import dstruct.dialects.pgsqldialect;
}
version( USE_MYSQL )
{
    public import dstruct.dialects.mysqldialect;
}
