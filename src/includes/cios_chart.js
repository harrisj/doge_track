---
layout: false
---
{% cios = Position.where(title_type: ["cto", "cio"]).order_by(:sort_date).all %}
{% positions_by_name = cios.group_by(&:name) %}
var options = {
  series: [
    {% positions_by_name.each do |name, positions| %}
    {
      name: '{{ name }}',
      data: [
        {% positions.each do |pos| %}
{
  'x': '{{ pos.agency_id }}',
    'y': [
      new Date('{{ pos.chart_start_date }}').getTime(),
      {% if pos.end_date %}new Date('{{ pos.chart_end_date }}').getTime(){% else %}Date.now(){% end %}
              ]
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
  },
  legend: {
    show: false,
  },
  colors: ['#008FFB', '#00E396', '#FEB019', '#FF4560', '#3F51B5', '#4CAF50', '#546E7A', '#D4526E', '#A5978B', '#81D4FA', '#662E9B', '#90EE7E'],
};

var cio_chart = new ApexCharts(document.querySelector("#chart"), options);
cio_chart.render();
