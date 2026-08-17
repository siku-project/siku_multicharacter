export const parentPortrait = (id: number): string => {
  if (id >= 42 && id <= 44) {
    return `images/parents/special_male_${id - 42}.webp`
  }

  if (id === 45) {
    return 'images/parents/special_female_0.webp'
  }

  if (id >= 21) {
    return `images/parents/female_${id - 21}.webp`
  }

  return `images/parents/male_${id}.webp`
}
