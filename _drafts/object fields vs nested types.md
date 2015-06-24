I've been working with ElasticSearch the past few weeks, improving our product's searching and filtering capabilities. We had a type mapping that looked a little like this:

    {
        "last_name": "Herbert",
        "first_name": "Frank",
        "book": {
            1: {
                "title": "Dune",
                "date": "1962"
            }
        }
    }

That is to say, we had a type with an object field. Now, querying the object field is fairly simple; you can simply access its fields via "book.title" and so on. However, this approach ceases to function if you wish to ensure that **you are returned a single result that matches all queries**.

If for instance you searched for a book title "Dune" with a date of "1965", the above query would return a result, despite their being no such book in the database!

In order to get around this, you need to represent the book as a nested type rather than an object field. This way, any query on its children will only return the book if *all* queries match.

There is, however, one gotcha: if you have a nested type, **you can no longer access it with dot notation**. Instead, you have to explicitly build nested queries, like so:

