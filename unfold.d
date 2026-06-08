/*
    This file is part of the Unfold distribution.

    https://github.com/senselogic/UNFOLD

    Copyright (C) 2026 Eric Pelzer (ecstatic.coder@gmail.com)

    Unfold is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Unfold is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Unfold.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : dirEntries, exists, isFile, mkdirRecurse, readText, rename, write, SpanMode;
import std.path : absolutePath;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith, strip, stripRight;

// -- VARIABLES

bool
    PreviewOptionIsEnabled;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

string GetPhysicalPath(
    string path
    )
{
    version( Windows )
    {
        return `\\?\` ~ path.absolutePath.replace( '/', '\\' ).replace( "\\.\\", "\\" );
    }

    return path;
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

string GetFolderPath(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ 0 .. slash_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

bool IsFolderPath(
    string folder_path
    )
{
    return
        folder_path == ""
        || folder_path.GetLogicalPath().endsWith( '/' );
}

// ~~

string GetFileName(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ slash_character_index + 1 .. $ ];
    }
    else
    {
        return file_path;
    }
}

// ~~

string GetFileStem(
    string file_path
    )
{
    long
        dot_character_index;
    string
        file_name;

    file_name = GetFileName( file_path );
    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        return file_name[ 0 .. dot_character_index ];
    }
    else
    {
        return file_name;
    }
}

// ~~

string GetFileExtension(
    string file_path
    )
{
    long
        dot_character_index;
    string
        file_name;

    file_name = GetFileName( file_path );
    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        return file_name[ dot_character_index .. $ ];
    }
    else
    {
        return "";
    }
}

// ~~

void CreateFolder(
    string folder_path
    )
{
    try
    {
        if ( folder_path != ""
             && folder_path != "/"
             && !folder_path.exists() )
        {
            writeln( "Creating folder : ", folder_path );

            folder_path.GetPhysicalPath().mkdirRecurse();
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void MoveFile(
    string old_file_path,
    string new_file_path
    )
{
    writeln( "Moving file :\n  ", old_file_path, "\n  ", new_file_path );

    try
    {
        if ( !PreviewOptionIsEnabled )
        {
            CreateFolder( new_file_path.GetFolderPath() );
            old_file_path.rename( new_file_path );
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't move file : " ~ old_file_path ~ " => " ~ new_file_path, exception );
    }
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    CreateFolder( file_path.GetFolderPath() );

    try
    {
        writeln( "Writing file : ", file_path );

        file_path.write( file_text );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

bool[ string ] GetRelativeFilePathExistsMap(
    string folder_path
    )
{
    bool[ string ]
        relative_file_path_exists_map;
    string
        file_path;

    writeln( "Reading folder : ", folder_path );

    if ( folder_path.exists() )
    {
        foreach ( folder_entry; folder_path.dirEntries( SpanMode.depth ) )
        {
            if ( folder_entry.isFile )
            {
                file_path = folder_entry.name.GetLogicalPath();

                if ( file_path.startsWith( folder_path ) )
                {
                    relative_file_path_exists_map[ file_path[ folder_path.length .. $ ] ] = true;
                }
            }
        }
    }

    return relative_file_path_exists_map;
}

// ~~

string[] GetRelativeFilePathArray(
    string folder_path,
    string file_name_filter
    )
{
    string
        file_path;
    string[]
        relative_file_path_array;

    writeln( "Filtering folder : ", folder_path );

    foreach ( folder_entry; folder_path.dirEntries( file_name_filter, SpanMode.depth ) )
    {
        if ( folder_entry.isFile )
        {
            file_path = folder_entry.name.GetLogicalPath();

            if ( file_path.startsWith( folder_path ) )
            {
                relative_file_path_array ~= file_path[ folder_path.length .. $ ];
            }
        }
    }

    return relative_file_path_array;
}

// ~~

string[ string ] GetPropertyValueByNameMap(
    string relative_file_path
    )
{
    long
        folder_number;
    string
        relative_folder_path;
    string[]
        relative_folder_name_array;
    string[ string ]
        property_value_by_name_map;

    property_value_by_name_map[ "P" ] = relative_file_path;

    relative_folder_path = relative_file_path.GetFolderPath();

    if ( relative_folder_path.endsWith( '/' ) )
    {
        relative_folder_name_array = relative_folder_path[ 0 .. $ - 1 ].split( '/' );
    }

    property_value_by_name_map[ "F" ] = relative_folder_path;

    foreach ( relative_folder_name_index, relative_folder_name; relative_folder_name_array )
    {
        folder_number = relative_folder_name_array.length - relative_folder_name_index;

        property_value_by_name_map[ "F" ~ folder_number.to!string() ] = relative_folder_name;
        property_value_by_name_map[ "F" ~ folder_number.to!string() ~ "-" ]
            = relative_folder_name_array[ 0 .. relative_folder_name_index + 1 ].join( '/' );
    }

    property_value_by_name_map[ "N" ] = relative_file_path.GetFileName();
    property_value_by_name_map[ "S" ] = relative_file_path.GetFileStem();
    property_value_by_name_map[ "E" ] = relative_file_path.GetFileExtension();

    return property_value_by_name_map;
}

// ~~

string GetOutputRelativeFilePath(
    string input_relative_file_path,
    string output_relative_file_path_template
    )
{
    long
        closing_brace_character_index;
    string
        property_expression,
        property_name;
    string*
        property_value;
    string[]
        part_array,
        property_filter_array;
    string[ string ]
        property_value_by_name_map;

    property_value_by_name_map = GetPropertyValueByNameMap( input_relative_file_path );

    part_array = output_relative_file_path_template.split( '{' );

    foreach ( part_index, part; part_array )
    {
        if ( part_index > 0 )
        {
            closing_brace_character_index = part.indexOf( '}' );

            if ( closing_brace_character_index >= 0 )
            {
                property_expression = part[ 0 .. closing_brace_character_index ];
                property_filter_array = property_expression.split( '|' );
                property_name = property_filter_array[ 0 ];
                property_value = property_name in property_value_by_name_map;

                if ( property_value !is null )
                {
                    part_array[ part_index ] = *property_value ~ part[ closing_brace_character_index + 1 .. $ ];
                }
                else if ( property_name.startsWith( 'F' ) )
                {
                    return "";
                }
                else
                {
                    Abort( "Invalid property name : " ~ property_name );
                }
            }
            else
            {
                Abort( "Invalid property : {" ~ part );
            }
        }
    }

    return part_array.join( "" );
}

// ~~

void ProcessFiles(
    string input_folder_path,
    string input_file_name_filter,
    string output_folder_path,
    string output_relative_file_path_template
    )
{
    bool[ string ]
        input_relative_file_path_exists_map,
        output_relative_file_path_exists_map;
    string
        input_file_path,
        output_file_path,
        output_relative_file_path;
    string[]
        input_relative_file_path_array;
    string[ string ]
        output_relative_file_path_map;

    input_relative_file_path_exists_map = GetRelativeFilePathExistsMap( input_folder_path );

    if ( !PreviewOptionIsEnabled )
    {
        CreateFolder( output_folder_path );
    }

    output_relative_file_path_exists_map = GetRelativeFilePathExistsMap( output_folder_path );

    input_relative_file_path_array = GetRelativeFilePathArray( input_folder_path, input_file_name_filter );

    foreach ( input_relative_file_path; input_relative_file_path_array )
    {
        writeln( "Checking file : ", input_relative_file_path );

        output_relative_file_path
            = GetOutputRelativeFilePath( input_relative_file_path, output_relative_file_path_template );

        if ( output_relative_file_path == "" )
        {
            writeln( "Skipping file : ", input_relative_file_path );
        }
        else
        {
            writeln( "Planning file : ", output_relative_file_path );

            output_relative_file_path_map[ input_relative_file_path ] = output_relative_file_path;

            if ( ( output_relative_file_path in output_relative_file_path_exists_map ) is null )
            {
                output_relative_file_path_exists_map[ output_relative_file_path ] = true;
            }
            else
            {
                Abort( "Output file will already exist : " ~ output_relative_file_path );
            }
        }
    }

    foreach ( input_relative_file_path; input_relative_file_path_array )
    {
        if ( ( input_relative_file_path in output_relative_file_path_map ) !is null )
        {
            output_relative_file_path = output_relative_file_path_map[ input_relative_file_path ];

            input_file_path = input_folder_path ~ input_relative_file_path;
            output_file_path = output_folder_path ~ output_relative_file_path;

            if ( output_file_path != input_file_path )
            {
                if ( !output_file_path.exists() )
                {
                    MoveFile( input_file_path, output_file_path );
                }
                else
                {
                    Abort( "Output file exists : " ~ output_file_path );
                }
            }
        }
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    argument_array = argument_array[ 1 .. $ ];

    PreviewOptionIsEnabled = false;

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--preview" )
        {
            PreviewOptionIsEnabled = true;
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length == 4
         && argument_array[ 0 ].GetLogicalPath().IsFolderPath()
         && argument_array[ 2 ].GetLogicalPath().IsFolderPath() )
    {
        ProcessFiles(
            argument_array[ 0 ].GetLogicalPath(),
            argument_array[ 1 ],
            argument_array[ 2 ].GetLogicalPath(),
            argument_array[ 3 ]
            );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    unfold <input folder path> <input file name filter> <output folder path> <output relative file path template>" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
