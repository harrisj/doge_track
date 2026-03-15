---
layout: false
---
function sameDay(d1, d2) {
  return d1.getFullYear() === d2.getFullYear() &&
    d1.getMonth() === d2.getMonth() &&
    d1.getDate() === d2.getDate();
}

{% cios = Position.where(title_type: ["cio"]).order_by(:sort_date).all %}
{% positions_by_name = cios.group_by(&:name) %}
var options = {
  series: [
    {% positions_by_name.each do |name, positions| %}
    {
      name: '{{ name }}',
      data: [
        {% positions.each do |pos| %}
            {   
                {% start_date = pos.start_date || pos.sort_date %}
                {% end_date = pos.end_date || Date.today %}
                'x': '{{ pos.agency_id }}',
                'y': [new Date('{{ start_date }}').getTime(), {% if pos.end_date %}new Date('{{ end_date }}').getTime(){% else %}Date.now(){% end %}]
            },
        {% end %}
      ]
    },
    {% end %}
  ],
  chart: {
    height: 450,
    type: 'rangeBar',
    toolbar: {
      show: false
    },
    fontFamily: "Raleway, system-ui, sans-serif",
    background: 'var(--chart-background)',
    foreColor: 'var(--chart-foreground)',
    zoom: {
      enabled: false
    }
  },
  plotOptions: {
    bar: {
      horizontal: true,
      rangeBarGroupRows: true,
      hideZeroBarsWhenGrouped: true
    }
  },
  xaxis: {
    type: 'datetime',
    max: Date.now(),
    min: new Date('2025-01-20').getTime(),
    labels: {
        format: 'MMM',
        hideOverlappingLabels: true,
        showDuplicates: false
    }
  },
  title: {
    text: 'DOGE CIOs Across Government',
    style: {
      fontSize:  '14px',
      fontWeight:  'bold',
      fontFamily:  "Raleway"
    }
  },
  legend: {
    show: false,
  },
  colors: ['#008FFB', '#00E396', '#FEB019', '#FF4560', '#3F51B5', '#4CAF50', '#546E7A', '#D4526E', '#A5978B', '#81D4FA', '#662E9B', '#90EE7E'],
  tooltip: {
            theme: 'var(--chart-tooltip-theme)',
            custom: function(opts) {
              const fromDate = new Date(opts.y1).toISOString().split('T')[0];
              const toDate = sameDay(new Date(opts.y2), new Date(Date.now())) ? 'today' : new Date(opts.y2).toISOString().split('T')[0];

              const w = opts.ctx.w
              let ylabel =
                w.config.series[opts.seriesIndex].data?.[opts.dataPointIndex]?.x
              let seriesName = w.config.series[opts.seriesIndex].name
                ? w.config.series[opts.seriesIndex].name
                : ''
              const color = w.globals.colors[opts.seriesIndex]

              return '<strong>' + seriesName + ' (' + ylabel + ')</strong>\n' + fromDate + ' to ' + toDate;
            }
    }
};

var cio_chart = new ApexCharts(document.querySelector("#cio-chart"), options);
cio_chart.render();
