<template>
  <div class="transaction-history">
    <div class="history-header">
      <h3>Transaction History</h3>
      <span class="transaction-count">{{ transactions.length }} operations</span>
    </div>

    <div class="history-content">
      <div class="list-view" data-test="transaction-history">
        <div
          v-for="transaction in transactions"
          :key="transaction.timestamp"
          class="transaction-entry"
          :class="transaction.operation.toLowerCase()"
        >
          <div class="transaction-icon">
            <Icon :icon="operationIcons[transaction.operation]" />
          </div>
          <div class="transaction-details">
            <span class="operation">{{ transaction.operation }}</span>
            <span class="timestamp">{{ formatTimestamp(transaction.timestamp) }}</span>
          </div>
          <div class="transaction-data">
            <Icon :icon="languageIcons[transaction.language]" class="language-icon" />
            <span class="text">{{ truncateText(transaction.text, 50) }}</span>
          </div>
        </div>
      </div>

      <div class="charts-view">
        <div class="chart-wrapper">
          <svg ref="operationsChart" class="operations-chart"></svg>
        </div>
        <div class="chart-wrapper">
          <svg ref="languagesChart" class="languages-chart"></svg>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { Icon } from '@iconify/vue'
import * as d3 from 'd3'
import type { Language } from '@/types/vow'

interface Transaction {
  operation: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE'
  timestamp: number
  language: Language
  text: string
}

const props = defineProps<{
  transactions: Transaction[]
}>()

const operationIcons = {
  CREATE: 'material-symbols:add-circle-outline',
  READ: 'material-symbols:menu-book-outline',
  UPDATE: 'material-symbols:edit-outline',
  DELETE: 'material-symbols:delete-outline',
}

const languageIcons = {
  typescript: 'logos:typescript-icon',
  go: 'logos:go',
  python: 'logos:python',
}

const operationsChart = ref<SVGElement>()
const languagesChart = ref<SVGElement>()

watch(() => props.transactions, updateCharts, { deep: true })

onMounted(() => {
  updateCharts()
})

function updateCharts() {
  renderOperationsChart()
  renderLanguagesChart()
}

function renderOperationsChart() {
  if (!operationsChart.value || !props.transactions.length) return

  const svg = d3.select(operationsChart.value)
  svg.selectAll('*').remove()

  const size = 100
  const margin = 10
  svg.attr('viewBox', `0 0 ${size} ${size}`).attr('preserveAspectRatio', 'xMidYMid meet')

  const operationCounts = Array.from(
    d3.group(props.transactions, (d) => d.operation),
    ([key, value]) => ({ operation: key, count: value.length }),
  )

  const radius = (size - margin * 2) * 0.35

  const color = d3
    .scaleOrdinal<string>()
    .domain(['CREATE', 'READ', 'UPDATE', 'DELETE'])
    .range(['#4CAF50', '#2196F3', '#FF9800', '#F44336'])

  const pie = d3
    .pie<{ operation: string; count: number }>()
    .value((d) => d.count)
    .sort(null)

  const arc = d3
    .arc<d3.PieArcDatum<{ operation: string; count: number }>>()
    .innerRadius(radius * 0.6)
    .outerRadius(radius)

  const g = svg.append('g').attr('transform', `translate(${size / 2},${size / 2})`)

  const path = g
    .selectAll('path')
    .data(pie(operationCounts))
    .enter()
    .append('path')
    .attr('d', arc)
    .attr('fill', (d) => color(d.data.operation))
    .attr('stroke', 'var(--bg-color)')
    .attr('stroke-width', 1.5)

  const labelArc = d3
    .arc<d3.PieArcDatum<{ operation: string; count: number }>>()
    .innerRadius(radius * 1.1)
    .outerRadius(radius * 1.1)

  g.selectAll('path.label-line')
    .data(pie(operationCounts))
    .enter()
    .append('path')
    .attr('class', 'label-line')
    .attr('d', (d) => {
      const pos = labelArc.centroid(d)
      return `M ${pos[0] * 0.95},${pos[1] * 0.95} L ${pos[0]},${pos[1]}`
    })
    .attr('stroke', 'var(--border-color)')
    .attr('stroke-width', 1)

  g.selectAll('text.operation-label')
    .data(pie(operationCounts))
    .enter()
    .append('text')
    .attr('class', 'operation-label')
    .attr('transform', (d) => {
      const pos = labelArc.centroid(d)
      return `translate(${pos[0] * 1.1},${pos[1] * 1.1})`
    })
    .attr('dy', '-0.5em')
    .attr('text-anchor', 'middle')
    .attr('fill', 'var(--text-color)')
    .attr('font-size', '8px')
    .attr('font-weight', 'bold')
    .text((d) => d.data.operation)

  g.selectAll('text.count-label')
    .data(pie(operationCounts))
    .enter()
    .append('text')
    .attr('class', 'count-label')
    .attr('transform', (d) => {
      const pos = labelArc.centroid(d)
      return `translate(${pos[0] * 1.1},${pos[1] * 1.1})`
    })
    .attr('dy', '1em')
    .attr('text-anchor', 'middle')
    .attr('fill', 'var(--text-muted)')
    .attr('font-size', '7px')
    .text((d) => `(${d.data.count})`)

  path
    .on('mouseenter', function () {
      const element = d3.select(this)
      element
        .transition()
        .duration(200)
        .attr('transform', (d) => {
          const [x, y] = arc.centroid(d as d3.PieArcDatum<{ operation: string; count: number }>)
          return `translate(${x * 0.05},${y * 0.05})`
        })
        .style('filter', 'brightness(1.1)')
    })
    .on('mouseleave', function () {
      const element = d3.select(this)
      element.transition().duration(200).attr('transform', 'translate(0,0)').style('filter', 'none')
    })
}

function renderLanguagesChart() {
  if (!languagesChart.value || !props.transactions.length) return

  const svg = d3.select(languagesChart.value)
  svg.selectAll('*').remove()

  const size = 100
  const margin = 10
  svg.attr('viewBox', `0 0 ${size} ${size}`).attr('preserveAspectRatio', 'xMidYMid meet')

  const languageCounts = Array.from(
    d3.group(props.transactions, (d) => d.language),
    ([key, value]) => ({ language: key, count: value.length }),
  )

  const radius = (size - margin * 2) * 0.3

  const color = d3
    .scaleOrdinal<string>()
    .domain(['typescript', 'go', 'python'])
    .range(['#3178C6', '#00ADD8', '#3776AB'])

  const pie = d3
    .pie<{ language: string; count: number }>()
    .value((d) => d.count)
    .sort(null)

  const arc = d3
    .arc<d3.PieArcDatum<{ language: string; count: number }>>()
    .innerRadius(radius * 0.6)
    .outerRadius(radius)

  const g = svg.append('g').attr('transform', `translate(${size / 2},${size / 2})`)

  const path = g
    .selectAll('path')
    .data(pie(languageCounts))
    .enter()
    .append('path')
    .attr('d', arc)
    .attr('fill', (d) => color(d.data.language))
    .attr('stroke', 'var(--bg-color)')
    .attr('stroke-width', 1.5)

  const iconSize = 14
  const iconArc = d3
    .arc<d3.PieArcDatum<{ language: string; count: number }>>()
    .innerRadius(radius * 1.2)
    .outerRadius(radius * 1.2)

  const icons = g
    .selectAll('g.icon-container')
    .data(pie(languageCounts))
    .enter()
    .append('g')
    .attr('class', 'icon-container')
    .attr('transform', (d) => {
      const [x, y] = iconArc.centroid(d)
      return `translate(${x},${y})`
    })

  icons.each(function (d) {
    const container = d3.select(this)

    const clipId = `clip-${d.data.language}-${d.index}`

    container
      .append('defs')
      .append('clipPath')
      .attr('id', clipId)
      .append('circle')
      .attr('r', iconSize / 2)
      .attr('cx', 0)
      .attr('cy', 0)

    container
      .append('circle')
      .attr('r', iconSize / 2)
      .attr('fill', d.data.language === 'typescript' ? '#3178C6' : 'var(--bg-color)')
      .attr('stroke', 'var(--border-color)')
      .attr('stroke-width', 1)

    if (d.data.language === 'typescript') {
      container
        .append('text')
        .attr('dy', '0.3em')
        .attr('text-anchor', 'middle')
        .attr('fill', 'white')
        .attr('font-size', `${iconSize * 0.5}px`)
        .attr('font-weight', '1000')
        .text('TS')
    } else {
      container
        .append('svg:image')
        .attr('width', iconSize * 0.8)
        .attr('height', iconSize * 0.8)
        .attr('x', -iconSize * 0.4)
        .attr('y', -iconSize * 0.4)
        .attr('clip-path', `url(#${clipId})`)
        .attr('href', () => {
          const icon = languageIcons[d.data.language as keyof typeof languageIcons]
          return `https://api.iconify.design/${icon.split(':')[0]}/${icon.split(':')[1]}.svg`
        })
    }
  })

  g.selectAll('text')
    .data(pie(languageCounts))
    .enter()
    .append('text')
    .attr('transform', (d) => {
      const [x, y] = iconArc.centroid(d)
      return `translate(${x},${y + iconSize})`
    })
    .attr('dy', '0.5em')
    .attr('text-anchor', 'middle')
    .attr('fill', 'var(--text-muted)')
    .attr('font-size', '7px')
    .text((d) => `(${d.data.count})`)

  path
    .on('mouseenter', function () {
      const element = d3.select(this)
      element
        .transition()
        .duration(200)
        .attr('transform', (d) => {
          const [x, y] = arc.centroid(d as d3.PieArcDatum<{ language: string; count: number }>)
          return `translate(${x * 0.05},${y * 0.05})`
        })
        .style('filter', 'brightness(1.1)')
    })
    .on('mouseleave', function () {
      const element = d3.select(this)
      element.transition().duration(200).attr('transform', 'translate(0,0)').style('filter', 'none')
    })
}

function formatTimestamp(timestamp: number): string {
  return new Date(timestamp).toLocaleTimeString()
}

function truncateText(text: string, length: number): string {
  return text.length > length ? text.slice(0, length) + '...' : text
}
</script>

<style scoped>
.transaction-history {
  height: 100%;
  max-height: 100%;
  min-height: 0;
  background-color: var(--code-bg);
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.history-header {
  flex-shrink: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-md);
  border-bottom: 1px solid var(--border-color);
}

.history-header h3 {
  margin: 0;
  font-size: 1rem;
}

.transaction-count {
  font-size: 0.875rem;
  opacity: 0.7;
}

.history-content {
  flex: 1;
  min-height: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-md);
  padding: var(--spacing-sm);
  overflow: hidden;
}

.list-view {
  overflow-y: auto;
  padding-right: var(--spacing-sm);
  border-right: 1px solid var(--border-color);
  height: 100%;
}

.charts-view {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
  overflow: hidden;
  height: 100%;
}

.chart-wrapper {
  flex: 1;
  min-height: 0;
  background: var(--code-bg);
  border-radius: 4px;
  border: 1px solid var(--border-color);
  padding: var(--spacing-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  width: 100%;
}

.chart-wrapper::before {
  content: '';
  display: block;
  padding-top: 100%;
}

.operations-chart,
.languages-chart {
  position: absolute;
  top: var(--spacing-sm);
  right: var(--spacing-sm);
  bottom: var(--spacing-sm);
  left: var(--spacing-sm);
  width: calc(100% - var(--spacing-sm) * 2);
  height: calc(100% - var(--spacing-sm) * 2);
  display: block;
}

.transaction-entry {
  display: grid;
  grid-template-columns: auto minmax(60px, auto) 1fr;
  align-items: center;
  padding: var(--spacing-sm);
  border-radius: 4px;
  margin-bottom: var(--spacing-sm);
  background-color: var(--button-bg);
  gap: var(--spacing-md);
}

.transaction-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
}

.transaction-details {
  display: flex;
  flex-direction: column;
  min-width: 60px;
}

.operation {
  font-weight: 500;
  font-size: 0.75rem;
  text-transform: capitalize;
}

.timestamp {
  font-size: 0.7rem;
  opacity: 0.7;
}

.transaction-data {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  font-size: 0.875rem;
  min-width: 0;
}

.language-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  min-width: 0;
}

.create {
  border-left: 3px solid #4caf50;
}
.read {
  border-left: 3px solid #2196f3;
}
.update {
  border-left: 3px solid #ff9800;
}
.delete {
  border-left: 3px solid #f44336;
}

.distribution-view {
  height: 100%;
}
</style>
