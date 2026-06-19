# Custom Cows

This guide shows you how to create your own cow characters for Forgum. It's fun and easy!

## How Cow Files Work

A cow file is a simple text file with a `.cow` extension. It contains ASCII art (pictures made with text characters) that Forgum puts inside the speech bubble.

## Step 1: Create a New Cow File

Create a new file called `mycow.cow` in the `Data/Cows/` folder (inside your Forgum installation).

## Step 2: Write Your Cow Art

Here's the simplest cow file:

```perl
$the_cow = <<EOC;
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||
EOC
```

That's it! Save the file and you're done.

## Understanding the Format

```perl
$the_cow = <<EOC;
    Your ASCII art goes here
    between the EOC markers
EOC
```

- `$the_cow = <<EOC;` — Starts the cow art
- `EOC` — Ends the cow art (must be on its own line)
- The art goes in between

## The Special Variables

You can use special variables in your cow art:

| Variable | What It Does | Example |
|:---------|:-------------|:--------|
| `$eyes` | Shows the eye characters | `oo` |
| `$tongue` | Shows the tongue characters | `  ` |
| `$thoughts` | Shows the thought bubble character | `\` |

### Example with Variables

```perl
$the_cow = <<EOC;
        \\   ^__^
         \\  ($eyes)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||
EOC
```

Now when someone uses `forgum -Eyes '@@'`, the cow will show `@@` instead of `oo`!

## Example Cows

### Simple Cat

```perl
$the_cow = <<EOC;
    /\\_/\\
   ( o.o )
    > ^ <
   /|   |\\
  (_|   |_)
EOC
```

### Robot

```perl
$the_cow = <<EOC;
    _____
   |     |
   | [$eyes] |
   |  ___  |
   | |   | |
   |_|___|_|
     |   |
    [_____] 
EOC
```

### Ghost

```perl
$the_cow = <<EOC;
     .-.
    (o o)
    | O |
    |   |
    '~~~'
EOC
```

### UFO

```perl
$the_cow = <<EOC;
        __
   \\  /  /
    \\/  /
     \\ /
     / \\
    /   \\
   /_____\\
      |
     [\\0/]
      |
     / \\
EOC
```

## Testing Your Cow

1. Save your `.cow` file in `Data/Cows/`
2. Run this command:

```powershell
forgum -Text "Hello from my cow!" -CowFile 'mycow'
```

## Tips for Good Cows

### 1. Keep It Small
Cows should fit in a terminal window. Aim for 20-30 characters wide.

### 2. Use Consistent Spacing
Line up your characters so the cow doesn't look crooked.

### 3. Test with Different Messages
Make sure your cow looks good with short and long messages.

### 4. Use the Variables
Use `$eyes` and `$tongue` so people can customize your cow.

### 5. ASCII Characters Only
Stick to standard ASCII characters (letters, numbers, symbols). Some special characters might not display correctly.

## Where to Find More Cows

- Look at the existing cows in `Data/Cows/` for inspiration
- Search online for "ASCII art" — there are thousands of designs!
- Try converting images to ASCII art with online tools

## Troubleshooting

**"Cow file not found"**
- Make sure the file is in `Data/Cows/`
- Make sure the filename is lowercase
- Don't include the `.cow` extension in the command

**Cow looks weird**
- Check for extra spaces or missing characters
- Try a different terminal font
- Make sure the art is properly aligned

**Cow is too big**
- Make the art smaller
- Increase `maxWidth` in your config: `$config.output.maxWidth = 80`

---

**Back:** [Configuration](Configuration) | **Next:** [Custom Fortunes →](Custom-Fortunes)
