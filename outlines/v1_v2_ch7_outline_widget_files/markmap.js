
HTMLWidgets.widget({

    name : 'markmap',
    type : 'output',
    initialize: function(el, width, height) {
        // this makes the svg object and attaches it to the
        //instance variable we call "theChart" in renderValue()
        var svg = d3.select(el).append("svg")
            .attr('class', "root")
            .attr('width', width)
            .attr('height', height)
            .attr("id","mindmap");
        return {
            svg:svg
        };

    }, //with initialize

    renderValue: function(el, x) {
        var elementId = el.id;
        //console.log(x.data);
        var data = parsemd(x.data);
        // select the svg element and remove existing children
        var svg = d3.select(el).select("svg");
        svg.selectAll("*").remove();
        markmap("svg#mindmap", data,x.options);
    },
    resize : function(el,width, height) {
        d3.select(el).select("svg")
            .attr("width", width)
            .attr("height", height);
    }

});
