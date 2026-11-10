import { describe, expect, it } from 'vitest'
import { greeting } from './greeting'

const at = (hour: number) => new Date(2026, 0, 1, hour)

describe('greeting', () => {
  it('knows the parts of the day', () => {
    expect(greeting(at(7))).toBe('Good morning')
    expect(greeting(at(15))).toBe('Good afternoon')
    expect(greeting(at(20))).toBe('Good evening')
    expect(greeting(at(2))).toBe('Good night')
  })
})
