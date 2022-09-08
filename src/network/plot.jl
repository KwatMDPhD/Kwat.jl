function plot(el_, st_, la; ou = "")

    di = "OnePiece.network.plot.$(OnePiece.time.stamp())"

    pr = splitext(basename(ou))[1]

    # TODO: Save with keyword argument

    OnePiece.html.make(
        di,
        [
            "http://ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js",
            "https://cdn.rawgit.com/eligrey/FileSaver.js/master/dist/FileSaver.js",
            "https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.21.1/cytoscape.min.js",
        ],
        """
        var cy = cytoscape({

            container: document.getElementById("$di"),

            elements: $(JSON3.write(el_)),

            style: $(JSON3.write(st_)),

            layout: $(JSON3.write(la)),

        });

        cy.ready(function() {

            let js = new Blob([JSON.stringify(cy.json(), null, 2)], {type: "application/json"});

            saveAs(js, "$pr.json");

            let pn = cy.png({"full": true, "scale": 1, "bg": "#fcc9b9"});

            saveAs(pn, "$pr.png");

        });
        """,
        ou,
    )

end
