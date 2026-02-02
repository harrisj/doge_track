---
layout: false
---
var month_totals = {{ site.data.month_totals | jsonify | raw }};

function data_labeler(val, opt) {
  console.log(val);
  if (opt.dataPointIndex > 0) {
    let key = opt.w.globals.labels[opt.dataPointIndex];
    prev_key = opt.w.globals.labels[opt.dataPointIndex-1];

    val = month_totals[key]["count"];
    added = month_totals[key]["join"]
    exit = month_totals[prev_key]["exit"]

    if (added == 0 && exit == 0) {
      return val;
    } else if (added > 0 && exit == 0) {
      return "" + val + " (+" + added + ")";
    } else if (added == 0 && exit > 0) {
      return "" + val + " (-" + exit + ")";
    } else {
      return "" + val + " (+" + added + " -" + exit + ")";
    }
  } else {
    return val;
  }
}

{% totals = site.data.month_totals %}
var options = {
  series: [{
    name: "DOGE Staffing",
    data: [
      {% totals.keys.sort.each do |key| %}
        {% total = totals[key] %}
        {
        x: '{{ key }}',
        y: {{ total['count'] }}
        },
      {% end %}
    ],
  }],
  plotOptions: {
    bar: {
      horizontal: true,
      barHeight: '95%',
      dataLabels: {
        position: 'top'
      }
    },
  },
  chart: {
    height: "400px",
    type: 'bar',
    toolbar: {
      show: false
    },
    fontSize:  '14px',
    fontFamily: "Roboto Mono, ui-monospace",
    background: 'var(--chart-background)',
    foreColor: 'var(--chart-foreground)',
    zoom: {
      enabled: false
    }
  },
  dataLabels: {
    enabled: true,
    style: {
        colors: ["var(--chart-foreground)"]
    },
    formatter: data_labeler,
    textAnchor: 'left',
    offsetX: 10
  },
  colors: ["var(--chart-foreground)"],
  grid: {
    yaxis: {
      lines: {
        show: false
      }
    }
  },
  tooltip: {
    enabled: false
  },
  legend: {
    show: false,
  },
};
var monthly_chart = new ApexCharts(document.querySelector("#chart"), options);
monthly_chart.render();
