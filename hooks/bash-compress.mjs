#!/usr/bin/env node

/**
 * Bash output compression hook for Claude Code.
 *
 * PostToolUse hook that compresses verbose bash output to save context tokens.
 * Adapted from clauditor's bash-filter (MIT licensed).
 *
 * What it does:
 * - Short output (<500 chars): passes through unchanged
 * - Strips progress bars and repeated lines
 * - Summarizes npm/pnpm/yarn install output
 * - For build output: keeps error/warn/fail lines + head/tail
 * - Final truncation at 2000 chars if still too long
 *
 * Hook reads from stdin, writes JSON to stdout.
 */

const PRESERVE_PATTERNS = [/error/i, /warn/i, /fail/i, /exception/i, /✗/]
const MAX_CHARS = 2000

function compress(output) {
  if (output.length < 500) return null

  const lines = output.split('\n')

  // Strip progress bars
  const filtered = lines.filter(
    l => !/\[=+[>\s]*\]/.test(l) && !/[█░▓▒]{3,}/.test(l)
  )

  // Collapse repeated lines
  const collapsed = []
  let lastLine = ''
  let repeatCount = 0
  for (const line of filtered) {
    if (line === lastLine) {
      repeatCount++
    } else {
      if (repeatCount > 1) collapsed.push(`[previous line repeated ${repeatCount} times]`)
      collapsed.push(line)
      lastLine = line
      repeatCount = 1
    }
  }
  if (repeatCount > 1) collapsed.push(`[previous line repeated ${repeatCount} times]`)

  let result

  // Package manager output — summarize heavily
  if (/added \d+ packages?/i.test(output) || /packages? are looking for funding/i.test(output)) {
    const head = collapsed.slice(0, 5)
    const tail = collapsed.slice(-5)
    const addedMatch = output.match(/added (\d+) packages?/i)
    const vulnMatch = output.match(/(\d+) vulnerabilit/i)
    const parts = [...head, '', `[... ${collapsed.length - 10} lines of install output omitted ...]`, '']
    if (addedMatch) parts.push(`Summary: ${addedMatch[0]}`)
    if (vulnMatch) parts.push(`Vulnerabilities: ${vulnMatch[0]}`)
    parts.push('', ...tail)
    result = parts.join('\n')
  } else {
    // Build/general output — keep important lines
    const important = collapsed.filter(l => PRESERVE_PATTERNS.some(p => p.test(l)))
    if (important.length > 0 && important.length < collapsed.length * 0.5) {
      const head = collapsed.slice(0, 5)
      const tail = collapsed.slice(-5)
      result = [
        ...head,
        `\n[... ${collapsed.length - 10} lines omitted, ${important.length} important lines below ...]\n`,
        ...important,
        '\n[... end of important lines ...]\n',
        ...tail,
      ].join('\n')
    } else {
      result = collapsed.join('\n')
    }
  }

  // Final truncation
  if (result.length > MAX_CHARS) {
    const headSize = Math.floor(MAX_CHARS * 0.4)
    const tailSize = Math.floor(MAX_CHARS * 0.4)
    result = result.slice(0, headSize) +
      `\n\n[... truncated ${result.length - headSize - tailSize} chars ...]\n\n` +
      result.slice(-tailSize)
  }

  if (result.length >= output.length) return null

  const origK = (output.length / 1000).toFixed(1)
  const compK = (result.length / 1000).toFixed(1)
  return `[bash-compress: ${origK}k → ${compK}k chars]\n${result}`
}

// --- Hook entry point ---
let data = ''
process.stdin.setEncoding('utf-8')
process.stdin.on('data', chunk => { data += chunk })
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data)

    if (input.tool_name !== 'Bash') {
      process.stdout.write('{}')
      return
    }

    const output = input.tool_response || ''
    const compressed = compress(output)

    if (compressed) {
      process.stdout.write(JSON.stringify({ additionalContext: compressed }))
    } else {
      process.stdout.write('{}')
    }
  } catch {
    process.stdout.write('{}')
  }
})
