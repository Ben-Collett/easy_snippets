# easy_snippets

easy snippets is a program that is written in dart used to allow you to define all your snippets in one place and generate snippets for your snippet engine, though currently luasnip is the only engine supported as that is the snippet engine I use

## how to run
clone the repo, 
```bash
git clone --depth 1 https://github.com/Ben-Collett/easy_snippets/
```
install the dart programing language, cd into easy_snippets,  and run dart main.dart \<options\> \<engine names\>
if no engine is specified then lua_snip will be used by default.
for more details on options and supported engines run dart main.dart help

##snippet syntax
Snippets live in the snippets/ directory by default, but you can point to another directory with the path="..." parameter when calling main.dart.

Defining a Snippet

Create a directory named after the programming language (e.g., python, dart, javascript).

Inside, create a text file with any extension and define snippets using the following syntax:
```txt
class {name}\{
   {content}
\}{_end}
```
Text inside {} marks a jump point in the snippet (if supported by the snippet engine).

Braces are not included in the final snippet text—only the name.

Escape a literal { or } with a backslash.

Escape backslashes themselves with \\.

Special characters like tabs require \\t

## snippet config
you can configure your snippets using the snip.json file in the snippets directory

you can specify your triggers by putting the name of your snippet file with out the extension as a key and using your desired trigger as the value this can be a single string or a list of strings if you want to support multiple triggers. If you do not set a trigger then the file name without the extension will be used by default.
snippets are auto epanding by default if you want to change that then set the auto_expand_by_default key to false 
you can also set triggers which use the opposite of the default behaior using the alternative_expanding list which takes a list of trigger strings and makes them do the nondefault behavior 
tab lets you set the string used for indentation if your snippet engine dosn't have any hard rules, defaults to two spaces
you can set a file path per engine using the name of the engine _path like lua_snip_path
you can also override a snippets behavior for a language by putting something like 
!OVERRIDES
{
"trigs": ["sout", "PRINT_PLZ "],
"autoexpand": ["PRINT_PLZ "]
}
!ENDOVERRIDES
at the top of your file this needs to start on the first line of the file and the contents must be valid json 
all override triggers are manual expanding by default 
you can also see an example config in the [snippets/](snippets) folder in the repo

## License

This project is licensed under [The Unlicense](LICENSE).

