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
import std.file : copy, dirEntries, exists, isFile, mkdirRecurse, readText, rename, write, SpanMode;
import std.path : absolutePath, globMatch;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith, strip, stripRight, toLower, toUpper;
import std.typecons : tuple, Tuple;
import std.uni : isAlpha;

// -- VARIABLES

bool
    CopyOptionIsEnabled,
    MoveOptionIsEnabled,
    OverwriteOptionIsEnabled,
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

bool IsNumberText(
    string text
    )
{
    foreach ( character; text )
    {
        if ( character < '0'
             || character > '9' )
        {
            return false;
        }
    }

    return true;
}

// ~~

string GetLowerCaseText(
    string text
    )
{
    return text.toLower();
}

// ~~

string GetUpperCaseText(
    string text
    )
{
    return text.toUpper();
}

// ~~

string GetTitleCaseText(
    string text
    )
{
    dchar
        prior_character;
    dstring
        unicode_text,
        title_case_text;

    unicode_text = text.to!dstring();
    prior_character = 0;

    foreach ( dchar character; unicode_text )
    {
        if ( character.isAlpha() )
        {
            if ( prior_character == 0
                 || prior_character == ' ' )
            {
                title_case_text ~= character.toUpper();
            }
            else
            {
                title_case_text ~= character.toLower();
            }
        }
        else
        {
            title_case_text ~= character;
        }

        prior_character = character;
    }


    return title_case_text.to!string();
}

// ~~

string AddPrefix(
    string text,
    string added_prefix
    )
{
    return added_prefix ~ text;
}

// ~~

string AddSuffix(
    string text,
    string added_suffix
    )
{
    return text ~ added_suffix;
}

// ~~

string RemovePrefix(
    string text,
    string removed_prefix
    )
{
    if ( text.startsWith( removed_prefix ) )
    {
        return text[ removed_prefix.length .. $ ];
    }
    else
    {
        return text;
    }
}

// ~~

string RemoveSuffix(
    string text,
    string removed_suffix
    )
{
    if ( text.endsWith( removed_suffix ) )
    {
        return text[ 0 .. $ - removed_suffix.length ];
    }
    else
    {
        return text;
    }
}

// ~~

string RemoveText(
    string text,
    string removed_text
    )
{
    return text.replace( removed_text, "" );
}

// ~~

string ReplacePrefix(
    string text,
    string old_prefix,
    string new_prefix
    )
{
    if ( text.startsWith( old_prefix ) )
    {
        return new_prefix ~ text[ old_prefix.length .. $ ];
    }
    else
    {
        return text;
    }
}

// ~~

string ReplaceSuffix(
    string text,
    string old_suffix,
    string new_suffix
    )
{
    if ( text.endsWith( old_suffix ) )
    {
        return text[ 0 .. $ - old_suffix.length ] ~ new_suffix;
    }
    else
    {
        return text;
    }
}

// ~~

string ReplaceText(
    string text,
    string old_text,
    string new_text
    )
{
    return text.replace( old_text, new_text );
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

string MakeFolderPath(
    string folder_path
    )
{
    if ( folder_path == ""
         || folder_path.endsWith( '/' ) )
    {
        return folder_path;
    }
    else
    {
        return folder_path ~ '/';
    }
}

// ~~

string MakeFolderPath(
    string[] folder_name_array
    )
{
    return folder_name_array.join( '/' ).MakeFolderPath();
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

string[] GetFolderPathPartArray(
    string path
    )
{
    string[]
        part_array;

    part_array = path.split( '/' );

    if ( part_array.length > 0
         && part_array[ 0 ] == "" )
    {
        part_array = part_array[ 1 .. $ ];
    }

    if ( part_array.length > 0
         && part_array[ $ - 1 ] == "" )
    {
        part_array = part_array[ 0 .. $ - 1 ];
    }

    return part_array;
}

// ~~

string[] GetFolderPathFilterPartArray(
    string folder_path_filter
    )
{
    long
        character_index,
        next_character_index;
    string[]
        filter_part_array;

    if ( !folder_path_filter.startsWith( "//" ) )
    {
        if ( folder_path_filter.startsWith( '/' ) )
        {
            folder_path_filter = folder_path_filter[ 1 .. $ ];
        }
        else
        {
            folder_path_filter = "//" ~ folder_path_filter;
        }
    }

    character_index = 0;

    while ( character_index < folder_path_filter.length )
    {
        if ( character_index + 1 < folder_path_filter.length
             && folder_path_filter[ character_index ] == '/'
             && folder_path_filter[ character_index + 1 ] == '/' )
        {
            filter_part_array ~= "//";
            character_index += 2;
        }
        else
        {
            next_character_index = character_index;

            while ( next_character_index < folder_path_filter.length
                    && folder_path_filter[ next_character_index ] != '/' )
            {
                ++next_character_index;
            }

            filter_part_array
                ~= folder_path_filter[ character_index .. next_character_index ];

            if ( next_character_index < folder_path_filter.length
                 && !( next_character_index + 1 < folder_path_filter.length
                       && folder_path_filter[ next_character_index ] == '/'
                       && folder_path_filter[ next_character_index + 1 ] == '/' ) )
            {
                ++next_character_index;
            }

            character_index = next_character_index;
        }
    }

    if ( filter_part_array.length > 0
         && filter_part_array[ $ - 1 ] == "" )
    {
        filter_part_array = filter_part_array[ 0 .. $ - 1 ];
    }

    return filter_part_array;
}

// ~~

bool MatchesFolderPathFilter(
    string[] folder_part_array,
    string[] filter_part_array,
    size_t folder_part_index,
    size_t filter_part_index
    )
{
    if ( filter_part_index >= filter_part_array.length )
    {
        return folder_part_index >= folder_part_array.length;
    }
    else if ( filter_part_array[ filter_part_index ] == "//" )
    {
        foreach ( next_folder_part_index; folder_part_index .. folder_part_array.length + 1 )
        {
            if ( MatchesFolderPathFilter( folder_part_array, filter_part_array, next_folder_part_index, filter_part_index + 1 ) )
            {
                return true;
            }
        }

        return false;
    }
    else if ( folder_part_index >= folder_part_array.length )
    {
        return false;
    }
    else if ( folder_part_array[ folder_part_index ].globMatch(
                  filter_part_array[ filter_part_index ] ) )
    {
        return MatchesFolderPathFilter( folder_part_array, filter_part_array, folder_part_index + 1, filter_part_index + 1 );
    }
    else
    {
        return false;
    }
}

// ~~

bool MatchesFilePathFilter(
    string file_path,
    string file_path_filter
    )
{
    string
        file_name,
        file_name_filter,
        folder_path,
        folder_path_filter;

    folder_path = file_path.GetFolderPath();
    file_name = file_path.GetFileName();

    folder_path_filter = file_path_filter.GetFolderPath();
    file_name_filter = file_path_filter.GetFileName();

    if ( folder_path_filter != "" )
    {
        if ( !MatchesFolderPathFilter(
                 folder_path.GetFolderPathPartArray(),
                 folder_path_filter.GetFolderPathFilterPartArray(),
                 0,
                 0 
                 ) )
        {
            return false;
        }
    }

    return
        file_name_filter == ""
        || file_name.globMatch( file_name_filter );
}

// ~~

bool MatchesFilePathFilterArray(
    string file_path,
    string[] file_path_filter_array
    )
{
    foreach ( file_path_filter; file_path_filter_array )
    {
        if ( MatchesFilePathFilter( file_path, file_path_filter ) )
        {
            return true;
        }
    }

    return false;
}

// ~~

void TestFilePathFilter(
    )
{
    Tuple!( string, string, bool )[]
        test_case_array;

    test_case_array = 
        [
            tuple( "DESIGN/DESKTOP/contact_code.html", "*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "//*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "*/*/*_code.html", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "//*/*/*_code.html", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "/DESKTOP//*.*", false ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "DESKTOP//*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "/DESIGN/*/*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "/DESIGN//*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "/DESIGN/DESKTOP/*.*|/DESIGN/MOBILE/*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "DESIGN/*/*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "DESIGN//*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "DESIGN/DESKTOP/*.*|DESIGN/MOBILE/*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_screen.png", "*/*/*_code.html", false ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "/DESIGN/*/*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "DESIGN/*/*.*", true ),
            tuple( "DESIGN/DESKTOP/contact_code.html", "DESIGN/*/*/*.*", false ),
            tuple( "A/B/DESIGN/DESKTOP/contact_code.html", "/DESIGN/*/*.*", false ),
            tuple( "A/B/DESIGN/DESKTOP/contact_code.html", "DESIGN/*/*.*", true ),
            tuple( "A/B/DESIGN/DESKTOP/contact_code.html", "DESIGN/*/*/*.*", false )
        ];

    foreach ( test_case; test_case_array )
    {
        if ( test_case[ 0 ].MatchesFilePathFilterArray( test_case[ 1 ].split( '|' ) )
             != test_case[ 2 ] )
        {
            writeln( test_case[ 0 ], " ", test_case[ 1 ], " ", test_case[ 2 ], " ", !test_case[ 2 ] );

            Abort( "Invalid file path filter test" );
        }
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

void CopyFile(
    string old_file_path,
    string new_file_path
    )
{
    writeln( "Copying file :\n  ", old_file_path, "\n  ", new_file_path );

    try
    {
        if ( !PreviewOptionIsEnabled )
        {
            CreateFolder( new_file_path.GetFolderPath() );
            old_file_path.copy( new_file_path );
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't copy file : " ~ old_file_path ~ " => " ~ new_file_path, exception );
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
    string file_path_filter
    )
{
    string
        file_path,
        relative_file_path;
    string[]
        file_path_filter_array,
        relative_file_path_array;

    writeln( "Filtering folder : ", folder_path );

    file_path_filter_array = file_path_filter.split( '|' );

    foreach ( folder_entry; folder_path.dirEntries( SpanMode.depth ) )
    {
        if ( folder_entry.isFile )
        {
            file_path = folder_entry.name.GetLogicalPath();

            if ( file_path.startsWith( folder_path ))
            {
                relative_file_path = file_path[ folder_path.length .. $ ];

                if ( relative_file_path.MatchesFilePathFilterArray( file_path_filter_array ) )
                {
                    relative_file_path_array ~= relative_file_path;
                }
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
        upper_folder_number,
        relative_folder_name_count;
    string
        relative_folder_name,
        relative_folder_path,
        upper_folder_number_text;
    string[]
        relative_folder_name_array;
    string[ string ]
        property_value_by_name_map;

    property_value_by_name_map[ "F" ] = relative_file_path;

    relative_folder_path = relative_file_path.GetFolderPath();

    if ( relative_folder_path.endsWith( '/' ) )
    {
        relative_folder_name_array = relative_folder_path[ 0 .. $ - 1 ].split( '/' );
    }
    else
    {
        relative_folder_name_array = relative_folder_path.split( '/' );
    }

    for ( upper_folder_number = 0;
          upper_folder_number < relative_folder_name_array.length;
          ++upper_folder_number )
    {
        relative_folder_name_count = relative_folder_name_array.length - upper_folder_number;

        if ( upper_folder_number > 0 )
        {
            upper_folder_number_text = upper_folder_number.to!string();
        }

        relative_folder_name = relative_folder_name_array[ relative_folder_name_count - 1 ];
        relative_folder_path = relative_folder_name_array[ 0 .. relative_folder_name_count ].MakeFolderPath();

        property_value_by_name_map[ "D" ~ upper_folder_number_text ] = relative_folder_path;
        property_value_by_name_map[ "D" ~ upper_folder_number_text ~ "~" ] = relative_folder_path.ReplaceSuffix( "/", "" );
        property_value_by_name_map[ "D" ~ upper_folder_number_text ~ "!" ] = relative_folder_name;
    }

    property_value_by_name_map[ "N" ] = relative_file_path.GetFileName();
    property_value_by_name_map[ "S" ] = relative_file_path.GetFileStem();
    property_value_by_name_map[ "E" ] = relative_file_path.GetFileExtension();

    return property_value_by_name_map;
}

// ~~

string GetFilteredValue(
    string value,
    string filter
    )
{
    long
        filter_argument_count;
    string
        filter_name;
    string[]
        filter_argument_array,
        filter_part_array;

    filter_part_array = filter.split( ' ' );

    foreach ( ref filter_part; filter_part_array )
    {
        filter_part = filter_part.replace( '¨', ' ' );
    }

    filter_name = filter_part_array[ 0 ];
    filter_argument_array = filter_part_array[ 1 .. $ ];
    filter_argument_count = filter_argument_array.length;

    if ( filter_name == "lower_case"
         && filter_argument_count == 0 )
    {
        return value.GetLowerCaseText();
    }
    else if ( filter_name == "upper_case"
         && filter_argument_count == 0 )
    {
        return value.GetUpperCaseText();
    }
    else if ( filter_name == "title_case"
         && filter_argument_count == 0 )
    {
        return value.GetTitleCaseText();
    }
    else if ( filter_name == "add_prefix"
              && filter_argument_count == 1 )
    {
        return value.AddPrefix( filter_argument_array[ 0 ] );
    }
    else if ( filter_name == "add_suffix"
              && filter_argument_count == 1 )
    {
        return value.AddSuffix( filter_argument_array[ 0 ] );
    }
    else if ( filter_name == "remove_prefix"
              && filter_argument_count == 1 )
    {
        return value.RemovePrefix( filter_argument_array[ 0 ] );
    }
    else if ( filter_name == "remove_suffix"
              && filter_argument_count == 1 )
    {
        return value.RemoveSuffix( filter_argument_array[ 0 ] );
    }
    else if ( filter_name == "remove_text"
              && filter_argument_count == 1 )
    {
        return value.RemoveText( filter_argument_array[ 0 ] );
    }
    else if ( filter_name == "replace_prefix"
              && filter_argument_count == 2 )
    {
        return value.ReplacePrefix( filter_argument_array[ 0 ], filter_argument_array[ 1 ] );
    }
    else if ( filter_name == "replace_suffix"
              && filter_argument_count == 2 )
    {
        return value.ReplaceSuffix( filter_argument_array[ 0 ], filter_argument_array[ 1 ] );
    }
    else if ( filter_name == "replace_text"
              && filter_argument_count == 2 )
    {
        return value.ReplaceText( filter_argument_array[ 0 ], filter_argument_array[ 1 ] );
    }
    else
    {
        Abort( "Invalid property filter : " ~ filter );

        return value;
    }
}

// ~~

string GetFilteredValue(
    string value,
    string[] filter_array
    )
{
    string
        filtered_value;

    filtered_value = value;

    foreach ( filter; filter_array )
    {
        filtered_value = filtered_value.GetFilteredValue( filter );
    }

    return filtered_value;
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
        property_expression_part_array;
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
                property_expression_part_array = property_expression.split( '|' );
                property_name = property_expression_part_array[ 0 ];
                property_value = property_name in property_value_by_name_map;

                if ( property_value !is null )
                {
                    part_array[ part_index ]
                        = ( *property_value ).GetFilteredValue( property_expression_part_array[ 1 .. $ ] )
                          ~ part[ closing_brace_character_index + 1 .. $ ];
                }
                else if ( property_name.startsWith( 'D' )
                          && property_name[ 1 .. $ ].IsNumberText() )
                {
                    part_array[ part_index ] = part[ closing_brace_character_index + 1 .. $ ];
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
    string input_file_path_filter,
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

    input_relative_file_path_array = GetRelativeFilePathArray( input_folder_path, input_file_path_filter );

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
            else if ( !OverwriteOptionIsEnabled )
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
                if ( OverwriteOptionIsEnabled
                     || !output_file_path.exists() )
                {
                    if ( CopyOptionIsEnabled )
                    {
                        CopyFile( input_file_path, output_file_path );
                    }
                    else if ( MoveOptionIsEnabled )
                    {
                        MoveFile( input_file_path, output_file_path );
                    }
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

    CopyOptionIsEnabled = false;
    MoveOptionIsEnabled = false;
    OverwriteOptionIsEnabled = false;
    PreviewOptionIsEnabled = false;

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--copy" )
        {
            CopyOptionIsEnabled = true;
        }
        else if ( option == "--move" )
        {
            MoveOptionIsEnabled = true;
        }
        else if ( option == "--overwrite" )
        {
            OverwriteOptionIsEnabled = true;
        }
        else if ( option == "--preview" )
        {
            PreviewOptionIsEnabled = true;
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length == 4
         && ( CopyOptionIsEnabled || MoveOptionIsEnabled )
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
        writeln( "    unfold [options] <input folder path> <input file path filter> <output folder path> <output relative file path template>" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
