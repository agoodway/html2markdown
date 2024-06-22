[Jump to content](#bodyContent) [/wiki/Main_Page](/wiki/Main_Page)
 [Search](/wiki/Special:Search)
 # Elixir (programming language)
 26 languages 
 
 From Wikipedia, the free encyclopedia
 
 Programming language running on the Erlang virtual machine
 
| [/wiki/File:Question_book-new.svg](/wiki/File:Question_book-new.svg) | This article **relies excessively on [references](/wiki/Wikipedia:Verifiability) to [primary sources](/wiki/Wikipedia:No_original_research#Primary,_secondary_and_tertiary_sources)** . Please improve this article by adding [secondary or tertiary sources](/wiki/Wikipedia:No_original_research#Primary,_secondary_and_tertiary_sources) . 

 *Find sources:*  ["Elixir" programming language](https://www.google.com/search?as_eq=wikipedia&q=%22Elixir%22+programming+language) – [news](https://www.google.com/search?tbm=nws&q=%22Elixir%22+programming+language+-wikipedia&tbs=ar:1)  **·** [newspapers](https://www.google.com/search?&q=%22Elixir%22+programming+language&tbs=bkt:s&tbm=bks)  **·** [books](https://www.google.com/search?tbs=bks:1&q=%22Elixir%22+programming+language+-wikipedia)  **·** [scholar](https://scholar.google.com/scholar?q=%22Elixir%22+programming+language)  **·** [JSTOR](https://www.jstor.org/action/doBasicSearch?Query=%22Elixir%22+programming+language&acc=on&wc=on) *( June 2023 )* *( [Learn how and when to remove this message](/wiki/Help:Maintenance_template_removal) )* |
| --- | --- |
 
| [/wiki/File:Elixir_programming_language_logo.png](/wiki/File:Elixir_programming_language_logo.png) Elixir |  |
| --- | --- |
| [Paradigms](/wiki/Programming_paradigm) | [multi-paradigm](/wiki/Multi-paradigm_programming_language) : [functional](/wiki/Functional_programming) , [concurrent](/wiki/Concurrent_programming) , [distributed](/wiki/Distributed_programming) , [process-oriented](/wiki/Process-oriented_programming) |
| [Designed by](/wiki/Software_design) | José Valim |
| First appeared | 2012 ; 12 years ago ( 2012 ) |
|  |  |
| [Stable release](/wiki/Software_release_life_cycle) | 1.17.1 <sup>[[1]](#cite_note-wikidata-3ad90aaf786e63a7494d32a6cccfc2c7021fa981-v12-1)</sup>  [https://www.wikidata.org/wiki/Q5362035?uselang=en#P348](https://www.wikidata.org/wiki/Q5362035?uselang=en#P348) / 18 June 2024 ; 3 days ago ( 18 June 2024 ) |
|  |  |
| [Typing discipline](/wiki/Type_system) | [dynamic](/wiki/Type_system) , [strong](/wiki/Strong_typing) |
| [Platform](/wiki/Computing_platform) | [Erlang](/wiki/Erlang_(programming_language)) |
| [License](/wiki/Software_license) | [Apache License 2.0](/wiki/Apache_License_2.0) <sup>[[2]](#cite_note-2)</sup> |
| [Filename extensions](/wiki/Filename_extension) | .ex, .exs |
| Website | [elixir-lang  .org](https://elixir-lang.org) |
| Influenced by |  |
| [Clojure](/wiki/Clojure) , [Erlang](/wiki/Erlang_(programming_language)) , [Ruby](/wiki/Ruby_(programming_language)) |  |
| Influenced |  |
| [Gleam](/wiki/Gleam_(programming_language)) , [LFE](/wiki/LFE_(programming_language)) |  |
 
**Elixir** is a [functional](/wiki/Functional_programming) , [concurrent](/wiki/Concurrent_computing) , [high-level](/wiki/High-level_programming_language) [general-purpose](/wiki/General-purpose_programming_language) [programming language](/wiki/Programming_language) that runs on the [BEAM](/wiki/BEAM_(Erlang_virtual_machine)) [virtual machine](/wiki/Virtual_machine) , which is also used to implement the [Erlang](/wiki/Erlang_(programming_language)) programming language. <sup>[[3]](#cite_note-:0-3)</sup> Elixir builds on top of Erlang and shares the same abstractions for building [distributed](/wiki/Distributed_computing) , [fault-tolerant](/wiki/Fault-tolerant) applications. Elixir also provides tooling and an [extensible](/wiki/Extensible) design. The latter is supported by compile-time [metaprogramming](/wiki/Metaprogramming) with [macros](/wiki/Macro_(computer_science)) and [polymorphism](/wiki/Polymorphism_(computer_science)) via protocols. <sup>[[4]](#cite_note-4)</sup>
 
The community organizes yearly events in the United States, <sup>[[5]](#cite_note-5)</sup> Europe, <sup>[[6]](#cite_note-6)</sup> and Japan, <sup>[[7]](#cite_note-7)</sup> as well as minor local events and conferences. <sup>[[8]](#cite_note-8)</sup> <sup>[[9]](#cite_note-9)</sup>
  
## History [ [edit](/w/index.php?title=Elixir_(programming_language)&action=edit&section=1) ]
 
José Valim created the Elixir programming language as a [research and development](/wiki/Research_and_development) project at Plataformatec. His goals were to enable higher extensibility and productivity in the Erlang VM while maintaining compatibility with Erlang's ecosystem. <sup>[[10]](#cite_note-10)</sup> <sup>[[11]](#cite_note-11)</sup>
 
Elixir is aimed at large-scale sites and apps. It uses features of [Ruby](/wiki/Ruby_(programming_language)) , Erlang, and [Clojure](/wiki/Clojure) to develop a high-concurrency and low-latency language. It was designed to handle large data volumes. Elixir is also used in telecommunications, e-commerce, and finance. <sup>[[12]](#cite_note-12)</sup>
 
In 2021, the Numerical Elixir effort was announced with the goal of bringing machine learning, neural networks, GPU compilation, data processing, and computational notebooks to the Elixir ecosystem. <sup>[[13]](#cite_note-13)</sup>
 
## Versioning [ [edit](/w/index.php?title=Elixir_(programming_language)&action=edit&section=2) ]
 
Each of the minor versions supports a specific range of Erlang/ [OTP](/wiki/Open_Telecom_Platform) versions. <sup>[[14]](#cite_note-14)</sup> The current stable release version is 1.17.1 <sup>[[1]](#cite_note-wikidata-3ad90aaf786e63a7494d32a6cccfc2c7021fa981-v12-1)</sup>  [https://www.wikidata.org/wiki/Q5362035?uselang=en#P348](https://www.wikidata.org/wiki/Q5362035?uselang=en#P348) .
 
## Features [ [edit](/w/index.php?title=Elixir_(programming_language)&action=edit&section=3) ]
 
- [Compiles](/wiki/Compiler) to [bytecode](/wiki/Bytecode) for the [BEAM virtual machine](/wiki/BEAM_(Erlang_virtual_machine)) of [Erlang](/wiki/Erlang_(programming_language)) . <sup>[[15]](#cite_note-elixirhome-15)</sup> Full interoperability with Erlang code, without [runtime](/wiki/Runtime_(program_lifecycle_phase)) impact.
- Scalability and fault-tolerance, thanks to Erlang's lightweight concurrency mechanisms <sup>[[15]](#cite_note-elixirhome-15)</sup>
- [Built-in tooling](/wiki/Mix_(build_tool)) for managing dependencies, code compilation, running tests, formatting code, remote debugging and more.
- An interactive [REPL](/wiki/Read%E2%80%93eval%E2%80%93print_loop) inside running programs, including [Phoenix](/wiki/Phoenix_(web_framework)) web servers, with code reloading and access to internal state
- Everything is an [expression](/wiki/Expression_(computer_science)) <sup>[[15]](#cite_note-elixirhome-15)</sup>
- [Pattern matching](/wiki/Pattern_matching) <sup>[[15]](#cite_note-elixirhome-15)</sup> to promote assertive code <sup>[[16]](#cite_note-16)</sup>
- Type hints for static analysis tools
- Immutable data, with an emphasis, like other [functional](/wiki/Functional_programming) languages, on [recursion](/wiki/Recursion_(computer_science)) and [higher-order functions](/wiki/Higher-order_function) instead of [side-effect](/wiki/Side-effect_(computer_science)) -based [looping](/wiki/Loop_(computing))
- [Shared nothing concurrent programming](/wiki/Shared_nothing_architecture) via message passing ( [actor model](/wiki/Actor_model) ) <sup>[[17]](#cite_note-17)</sup>
- [Lazy](/wiki/Lazy_evaluation) and [async collections](/wiki/Futures_and_promises) with streams
- Railway oriented programming via the `with` construct <sup>[[18]](#cite_note-18)</sup>
- Hygienic [metaprogramming](/wiki/Metaprogramming) by direct access to the [abstract syntax tree](/wiki/Abstract_syntax_tree) (AST). <sup>[[15]](#cite_note-elixirhome-15)</sup> Libraries often implement small [domain-specific languages](/wiki/Domain-specific_language) , such as for databases or testing.
- Code execution at compile time. The Elixir compiler also runs on the BEAM, so modules that are being compiled can immediately run code which has already been compiled.
- [Polymorphism](/wiki/Polymorphism_(computer_science)) via a mechanism called protocols. [Dynamic dispatch](/wiki/Dynamic_dispatch) , as in [Clojure](/wiki/Clojure) , however, without [multiple dispatch](/wiki/Multiple_dispatch) because Elixir protocols dispatch on a single type.
- Support for documentation via Python-like docstrings in the [Markdown](/wiki/Markdown) formatting language <sup>[[15]](#cite_note-elixirhome-15)</sup>
- [Unicode](/wiki/Unicode) support and [UTF-8](/wiki/UTF-8) strings
 
## Examples [ [edit](/w/index.php?title=Elixir_(programming_language)&action=edit&section=4) ]
 
The following examples can be run in an `iex` [shell](/wiki/Shell_(computing)) or saved in a file and run from the [command line](/wiki/Command_line) by typing `elixir *<filename>*` .
 
Classic [Hello world](/wiki/%22Hello,_World!%22_program) example:
 ```
iex> IO . puts ( "Hello World!" ) Hello World!
```
 
Pipe operator:
 ```
iex> "Elixir"  |>  String . graphemes ()  |>  Enum . frequencies () %{"E" => 1, "i" => 2, "l" => 1, "r" => 1, "x" => 1} iex> %{ values :  1 .. 5 }  |>  Map . get ( :values )  |>  Enum . map ( &  &1  *  2 ) [2, 4, 6, 8, 10] iex> |>  Enum . sum () 30
```
 
[Pattern matching](/wiki/Pattern_matching) (a.k.a. destructuring):
 ```
iex> %{ left :  x }  =  %{ left :  5 ,  right :  8 } iex> x 5 iex> { :ok ,  [ _  |  rest ]}  =  { :ok ,  [ 1 ,  2 ,  3 ]} iex> rest [2, 3]
```
 
Pattern matching with multiple clauses:
 ```
iex> case  File . read ( "path/to/file" )  do iex>  { :ok ,  contents }  ->  IO . puts ( "found file: #{ contents } " ) iex>  { :error ,  reason }  ->  IO . puts ( "missing file: #{ reason } " ) iex> end
```
 
[List comprehension](/wiki/List_comprehension) :
 ```
iex> for  n  <-  1 .. 5 ,  rem ( n ,  2 )  ==  1 ,  do :  n * n [1, 9, 25]
```
 
Asynchronously reading files with streams:
 ```
1 .. 5 |>  Task . async_stream ( & File . read! ( " #{ &1 } .txt" )) |>  Stream . filter ( fn  { :ok ,  contents }  ->  String . trim ( contents )  !=  ""  end ) |>  Enum . join ( " \n " )
```
 
Multiple function bodies with [guards](/wiki/Guard_(computer_science)#Mathematics) :
 ```
def  fib ( n )  when  n  in  [ 0 ,  1 ],  do :  n def  fib ( n ),  do :  fib ( n - 2 )  +  fib ( n - 1 )
```
 
Relational databases with the Ecto library:
 ```
schema  "weather"  do  field  :city  # Defaults to type :string  field  :temp_lo ,  :integer  field  :temp_hi ,  :integer  field  :prcp ,  :float ,  default :  0.0 end Weather  |>  where ( city :  "Kraków" )  |>  order_by ( :temp_lo )  |>  limit ( 10 )  |>  Repo . all
```
 
Sequentially spawning a thousand processes:
 ```
for  num  <-  1 .. 1000 ,  do :  spawn  fn  ->  IO . puts ( " #{ num  *  2 } " )  end
```
 
[Asynchronously](/wiki/Async/await) performing a task:
 ```
task  =  Task . async  fn  ->  perform_complex_action ()  end other_time_consuming_action () Task . await  task
```
 
<sup>[ *[citation needed](/wiki/Wikipedia:Citation_needed)* ]</sup>
 
## See also [ [edit](/w/index.php?title=Elixir_(programming_language)&action=edit&section=5) ]
 
- [Free and open-source software portal](/wiki/Portal:Free_and_open-source_software)
 
- [Concurrent computing](/wiki/Concurrent_computing)
- [Distributed computing](/wiki/Distributed_computing)
- [Parallel computing](/wiki/Parallel_computing)
 
## References [ [edit](/w/index.php?title=Elixir_(programming_language)&action=edit&section=6) ]
 1. ^ [<sup>***a***</sup>](#cite_ref-wikidata-3ad90aaf786e63a7494d32a6cccfc2c7021fa981-v12_1-0) [<sup>***b***</sup>](#cite_ref-wikidata-3ad90aaf786e63a7494d32a6cccfc2c7021fa981-v12_1-1) ["Release 1.17.1"](https://github.com/elixir-lang/elixir/releases/tag/v1.17.1) . 18 June 2024 . Retrieved 21 June 2024 .
2. **[^](#cite_ref-2)** ["elixir/LICENSE at master · elixir-lang/elixir · GitHub"](https://github.com/elixir-lang/elixir/blob/master/LICENSE) . *GitHub* .
3. **[^](#cite_ref-:0_3-0)** ["Most Popular Programming Languages of 2018 - Elite Infoworld Blog"](https://web.archive.org/web/20180509080342/https://www.eliteinfoworld.com/blog/popular-programming-languages-2018/) . 2018-03-30. Archived from [the original](https://www.eliteinfoworld.com/blog/popular-programming-languages-2018/) on 2018-05-09 . Retrieved 2018-05-08 .
4. **[^](#cite_ref-4)** ["Elixir"](https://elixir-lang.org) . *José Valim* . Retrieved 2013-02-17 .
5. **[^](#cite_ref-5)** ["ElixirConf"](http://elixirconf.com/) . Retrieved 2018-07-11 .
6. **[^](#cite_ref-6)** ["ElixirConf"](http://elixirconf.eu/) . Retrieved 2018-07-11 .
7. **[^](#cite_ref-7)** ["Erlang & Elixir Fest"](https://elixir-fest.jp/) . Retrieved 2019-02-18 .
8. **[^](#cite_ref-8)** ["Elixir LDN"](http://www.elixir.london/) . Retrieved 2018-07-12 .
9. **[^](#cite_ref-9)** ["EMPEX - Empire State Elixir Conference"](http://empex.co/) . Retrieved 2018-07-12 .
10. **[^](#cite_ref-10)** [*Elixir - A modern approach to programming for the Erlang VM*](https://vimeo.com/53221562) . Retrieved 2013-02-17 .
11. **[^](#cite_ref-11)** [*José Valim - ElixirConf EU 2017 Keynote*](https://www.youtube.com/watch?v=IZvpKhA6t8A) . [Archived](https://ghostarchive.org/varchive/youtube/20211117/IZvpKhA6t8A) from the original on 2021-11-17 . Retrieved 2017-07-14 .
12. **[^](#cite_ref-12)** ["Behinde the code: The One Who Created Elixir"](https://www.welcometothejungle.com/en/articles/btc-elixir-jose-valim/) . Retrieved 2019-11-25 .
13. **[^](#cite_ref-13)** ["Numerical Elixir (Nx)"](https://github.com/elixir-nx) . Retrieved 2024-05-06 .
14. **[^](#cite_ref-14)** [*Elixir is a dynamic, functional language designed for building scalable and maintainable applications: elixir-lang/elixir*](https://github.com/elixir-lang/elixir) , Elixir, 2019-04-21 , retrieved 2019-04-21
15. ^ [<sup>***a***</sup>](#cite_ref-elixirhome_15-0) [<sup>***b***</sup>](#cite_ref-elixirhome_15-1) [<sup>***c***</sup>](#cite_ref-elixirhome_15-2) [<sup>***d***</sup>](#cite_ref-elixirhome_15-3) [<sup>***e***</sup>](#cite_ref-elixirhome_15-4) [<sup>***f***</sup>](#cite_ref-elixirhome_15-5) ["Elixir"](https://elixir-lang.org/) . Retrieved 2014-09-07 .
16. **[^](#cite_ref-16)** ["Writing assertive code with Elixir"](http://blog.plataformatec.com.br/2014/09/writing-assertive-code-with-elixir/) . 24 September 2014 . Retrieved 2018-07-05 .
17. **[^](#cite_ref-17)** Loder, Wolfgang (12 May 2015). [*Erlang and Elixir for Imperative Programmers*](https://leanpub.com/erlangandelixirforimperativeprogrammers) . "Chapter 16: Code Structuring Concepts", section title "Actor Model": Leanpub . Retrieved 7 July 2015 .  `{{ [cite book](/wiki/Template:Cite_book) }}` :  CS1 maint: location ( [link](/wiki/Category:CS1_maint:_location) )
18. **[^](#cite_ref-18)** Wlaschin, Scott (May 2013). ["Railway Oriented Programming"](https://fsharpforfunandprofit.com/rop/) . *F# for Fun and Profit* . [Archived](https://web.archive.org/web/20210130221804/http://fsharpforfunandprofit.com/rop/) from the original on 30 January 2021 . Retrieved 28 February 2021 .
 
## Further reading [ [edit](/w/index.php?title=Elixir_(programming_language)&action=edit&section=7) ]
 
- Simon St. Laurent; J. Eisenberg (December 22, 2016). *Introducing Elixir: Getting Started in Functional Programming 2nd Edition* . [O'Reilly Media](/wiki/O%27Reilly_Media) . [ASIN](/wiki/ASIN_(identifier))  [B01N9KCTIC](https://www.amazon.com/dp/B01N9KCTIC) . [ISBN](/wiki/ISBN_(identifier))  [978-1491956779](/wiki/Special:BookSources/978-1491956779) .
- Sasa Juric (January 12, 2019). *Elixir in Action 2nd Edition* . [Manning Publications](/wiki/Manning_Publications) . [ASIN](/wiki/ASIN_(identifier))  [B0978KZTJG](https://www.amazon.com/dp/B0978KZTJG) . [ISBN](/wiki/ISBN_(identifier))  [978-1617295027](/wiki/Special:BookSources/978-1617295027) .
 [Categories](/wiki/Help:Category) : 
- [Concurrent programming languages](/wiki/Category:Concurrent_programming_languages)
- [Functional languages](/wiki/Category:Functional_languages)
- [Pattern matching programming languages](/wiki/Category:Pattern_matching_programming_languages)
- [Programming languages](/wiki/Category:Programming_languages)
- [Programming languages created in 2012](/wiki/Category:Programming_languages_created_in_2012)
- [Software using the Apache license](/wiki/Category:Software_using_the_Apache_license)
 Hidden categories: 
- [CS1 maint: location](/wiki/Category:CS1_maint:_location)
- [Articles with short description](/wiki/Category:Articles_with_short_description)
- [Short description is different from Wikidata](/wiki/Category:Short_description_is_different_from_Wikidata)
- [Articles lacking reliable references from June 2023](/wiki/Category:Articles_lacking_reliable_references_from_June_2023)
- [All articles lacking reliable references](/wiki/Category:All_articles_lacking_reliable_references)
- [All articles with unsourced statements](/wiki/Category:All_articles_with_unsourced_statements)
- [Articles with unsourced statements from June 2023](/wiki/Category:Articles_with_unsourced_statements_from_June_2023)
- [Articles with J9U identifiers](/wiki/Category:Articles_with_J9U_identifiers)
- [Articles with LCCN identifiers](/wiki/Category:Articles_with_LCCN_identifiers)
 -