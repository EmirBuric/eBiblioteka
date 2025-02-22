using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class KnjigaAutor
{
    public int KnjigaAutorId { get; set; }

    public int? KnjigaId { get; set; }

    public int? AutorId { get; set; }

    public virtual Autor? Autor { get; set; }

    public virtual Knjiga? Knjiga { get; set; }
}
