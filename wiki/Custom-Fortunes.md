# Custom Fortunes

This guide shows you how to add your own quotes and sayings to Forgum. You can add jokes, inspirational quotes, programming humor — anything you want!

## How Fortunes Work

Forgum reads fortunes from a text file. Each fortune is separated by a special character: `%`. When you run `forgum`, it picks a random fortune from the file.

## Step 1: Find the Fortune File

Your fortune file is located at:
- **Windows**: `~/Documents/PowerShell/fortunes.txt`
- **Mac/Linux**: `~/.local/share/powershell/Modules/Forgum/Data/Fortunes/fortunes.txt`

## Step 2: Add Your Fortunes

Open the file in any text editor and add your fortunes at the end. Each fortune must be separated by `%`.

### Format

```
First fortune here
%
Second fortune here
%
Third fortune here
%
```

### Example

```
The only way to do great work is to love what you do.
%
Innovation distinguishes between a leader and a follower.
%
Stay hungry, stay foolish.
%
Your time is limited, don't waste it living someone else's life.
%
```

## Step 3: Save and Test

Save the file and run:

```powershell
Get-Fortune
```

You should see one of your new fortunes!

## Fortune Categories

You can organize your fortunes by creating separate files. Forgum supports multiple fortune databases.

### Creating a Custom Fortune File

1. Create a new file in the same folder as `fortunes.txt`
2. Name it something like `programming.txt` or `jokes.txt`
3. Add your fortunes in the same format

### Using Your Custom File

```powershell
# Use your custom fortune file
Get-Fortune -Database 'programming'

# Or set it as default
$config = Get-CFConfig
$config.fortune.database = 'programming'
Set-CFConfig -Config $config
```

## Fortune Ideas

### Inspirational Quotes
```
The future belongs to those who believe in the beauty of their dreams.
%
It does not matter how slowly you go as long as you do not stop.
%
Everything you've ever wanted is on the other side of fear.
```

### Programming Humor
```
There are only 10 types of people in the world: those who understand binary and those who don't.
%
A SQL query walks into a bar, sees two tables and asks: "Can I join you?"
%
Why do programmers prefer dark mode? Because light attracts bugs.
```

### Funny Quotes
```
I'm not superstitious, but I am a little stitious.
%
I always wanted to be somebody, but now I realize I should have been more specific.
%
If at first you don't succeed, skydiving is not for you.
```

### Daily Motivation
```
Today is a good day to have a good day.
%
Be the change you wish to see in the world.
%
The best time to plant a tree was 20 years ago. The second best time is now.
```

### Tech Quotes
```
First, solve the problem. Then, write the code.
%
Programs must be written for people to read, and only incidentally for machines to execute.
%
Any fool can write code that a computer can understand. Good programmers write code that humans can understand.
```

## Multi-Line Fortunes

Fortunes can span multiple lines. Just make sure the `%` separator is on its own line:

```
This is a long fortune
that spans multiple lines
and is still one fortune.
%
This is another fortune
with two lines.
%
```

## Special Characters

You can use any characters in your fortunes, but avoid:
- `%` (unless it's the separator)
- Very long lines (they might wrap oddly)
- Control characters (they might not display)

## Tips

### Keep It Short
Short fortunes display better in the cow's speech bubble. Aim for 1-3 lines.

### Mix It Up
Add a variety of fortunes — funny, inspirational, serious. You never know what someone needs to hear that day.

### Update Regularly
Add new fortunes from time to time to keep things fresh.

### Test Your Fortunes
Run `Get-Fortune` a few times to make sure your new fortunes display correctly.

## Managing Large Collections

If you have hundreds of fortunes, consider splitting them into multiple files:

```
Data/Fortunes/
├── fortunes.txt (main collection)
├── programming.txt (tech humor)
├── jokes.txt (funny quotes)
└── inspirational.txt (motivational)
```

Then use them with:
```powershell
Get-Fortune -Database 'programming'
```

## Troubleshooting

**"Fortune file not found"**
- Check that the file exists in the correct location
- Make sure the filename is correct (case-sensitive on Mac/Linux)

**Fortune shows weird characters**
- Make sure the file is saved in UTF-8 encoding
- Avoid special characters that might not display

**Same fortune keeps appearing**
- Forgum is random! You might just be unlucky. Try running it more times.
- Add more fortunes to increase variety.

---

**Back:** [Custom Cows](Custom-Cows) | **Next:** [Troubleshooting →](Troubleshooting)
