<script context="module">
    // moment.locale(navigator.language)
</script>

<script>
    import Chart from 'chart.js';

    export let chartData;

    function canvasMounted (canvas, chartData) {
        let ctx = canvas.getContext('2d');

        const height = canvas.height;

        let chart = new Chart(ctx, {
            // The type of chart we want to create
            type: 'line',

            // The data for our dataset
            data: {
                datasets: [{
                    borderColor: '#003b68',
                    data: chartData,
                }],
            },

            // Configuration options go here
            options: {
                legend: {display: false},
                maintainAspectRatio: false,
                tooltips: {
                    mode: 'nearest',
                    intersect: false
                },
                scales: {
                    xAxes: [{
                        type: 'time',
                        time: {
                            displayFormats: {
                                hour: 'ddd hA',
                            },
                            tooltipFormat: 'MMM DD HH:mm',
                        },
                    }]
                },
            }
        });

        // hack to keep height. For some reason after initialiazing chart, it forgets it.  --_(=/)_--
        canvas.height=height;
        canvas.style.height=`${height}px`;
        canvas.style.width="100%";

        return {
            update(chartData) {
                chart.data.datasets[0].data = chartData;
                chart.update();
            }
        }

    }
    
</script>

<canvas use:canvasMounted={chartData} height="150"></canvas>