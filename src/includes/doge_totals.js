---
layout: false
---
var month_totals = {{ site.data.month_totals | jsonify | raw }};

function data_labeler(val, opt) {
  if (opt.dataPointIndex > 0) {
    let key = opt.w.globals.labels[opt.dataPointIndex];
    let prev_key = opt.w.globals.labels[opt.dataPointIndex - 1];

    val = month_totals[key]["count"];
    let added = month_totals[key]["join"];
    let exit = month_totals[prev_key]["exit"];

    if (added == 0 && exit == 0) {
      return "" + val;
    } else if (added > 0 && exit == 0) {
      return "" + val + " (+" + added + ")";
    } else if (added == 0 && exit > 0) {
      return "" + val + " (-" + exit + ")";
    } else {
      return "" + val + " (+" + added + " -" + exit + ")";
    }
  } else {
    return "" + val;
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
    textAnchor: 'left',
    offsetX: 5
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
  title: {
    text: 'DOGE Staffing Per Month',
    style: {
      fontSize: '18px',
      fontWeight: 'bold',
      fontFamily: "Raleway"
    }
  },
  legend: {
    show: false,
  },
  xaxis: {
    axisBorder: {
      show: false
    },
    labels: {
      show: true,
      hideOverlappingLabels: true,
      showDuplicates: false,
      style: {
        fontSize: '12px',
        fontFamily: 'Roboto Mono, ui-monospace'
      }
    }
  },
  yaxis: {
    labels: {
      offsetY: 3,
      style: {
        fontSize: '12px',
        fontFamily: 'Roboto Mono, ui-monospace'
      }
    }
  }
};

(function() {
  const initChart = () => {
    const container = document.querySelector("#chart");
    if (!container) return;

    // Cleanup any existing instance on this element
    if (container._apexChartInstance && typeof container._apexChartInstance.destroy === 'function') {
      container._apexChartInstance.destroy();
    }

    try {
      container._apexChartInstance = new ApexCharts(container, options);
      container._apexChartInstance.render();
      
      // Trigger resize to ensure dimensions are correct after DOM/layout settled
      window.dispatchEvent(new Event('resize'));
    } catch (e) {
      console.error("ApexCharts initialization failed:", e);
    }
  };

  const pollForElement = () => {
    let attempts = 0;
    const interval = setInterval(() => {
      attempts++;
      if (document.querySelector("#chart") || attempts > 20) {
        clearInterval(interval);
        if (document.querySelector("#chart")) {
          initChart();
        }
      }
    }, 50);
  };

  pollForElement();
})();
