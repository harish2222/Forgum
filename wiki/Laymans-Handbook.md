# 🐄 Layman's Handbook

Welcome to **Forgum**! If you're new to using the command line (that window where you type text commands), don't worry—this guide is just for you. Forgum is all about adding a bit of personality and fun to your workspace.

---

## 🌟 What is Forgum?

Think of Forgum as a digital pet that lives in your command line. It can:
1. **Talk**: You can make it say anything you want.
2. **Predict**: It can give you a "fortune" (a random quote or piece of advice).
3. **Be Colorful**: It can turn into a beautiful rainbow.
4. **Animate**: It can move, blink, or even "bounce" onto your screen.

---

## 🚀 Getting Started

If you've already installed Forgum, try typing this and hitting Enter:

```powershell
Invoke-Forgum -Lolcat
```

You should see a colorful animal sharing a bit of wisdom!

---

## 🎨 Fun Things to Try

### 1. Change the Character
We have **107 different characters** (we call them "cows," even if they're dragons or cats). To see a specific one, try:

```powershell
# Make a dragon talk
Invoke-Cowsay -Text "I am legendary!" -CowFile dragon

# Make a kitty talk
Invoke-Cowsay -Text "Feed me." -CowFile kitty
```

### 2. Rainbow Everything!
Want to see those colors? Just add `-Lolcat` to almost any command:

```powershell
Invoke-Cowsay -Text "Rainbows are great!" -Lolcat
```

### 3. See a Random Gallery
Can't decide which character you like? Let Forgum show you a random selection:

```powershell
cowgallery -Count 3
```

---

## 🛠 Simple Customizing

### Changing the Eyes
You can change how your character looks by changing its eyes:

```powershell
# "Dead" eyes
Invoke-Cowsay -Text "I'm a zombie!" -Eyes xx

# "Greedy" eyes
Invoke-Cowsay -Text "I love money!" -Eyes $$

# "Paranoid" eyes
Invoke-Cowsay -Text "Who's there?" -Eyes @@
```

### Changing the Colors
If you want the rainbow colors to be more or less frequent, you can use our easy toggle:

```powershell
# Turn rainbow colors on or off
lolcat-toggle
```

---

## ❓ Frequently Asked Questions

**"How do I see all the characters?"**
Type `Get-CFCow` to see a big list of every character name you can use.

**"Can I make it talk whenever I open my command line?"**
Yes! During the setup (when you ran `setup.ps1`), if you chose "Yes" for the startup option, it will greet you every time you start working.

**"What if I get stuck?"**
Don't be afraid to experiment! You can't break anything by just making a cow talk. If you want to see all the "pro" options, you can always type `help Invoke-Cowsay`.

---

## ❤️ Enjoy your new digital companion!

Forgum is meant to be fun. If you find a character you love or a funny quote, share it with your friends!
