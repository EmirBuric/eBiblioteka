using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Autor
{
    public int AutorId { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public DateTime? DatumRodjenja { get; set; }

    public string? Biografija { get; set; }

    public byte[]? Slika { get; set; }

    public virtual ICollection<KnjigaAutor> KnjigaAutors { get; set; } = new List<KnjigaAutor>();
}
