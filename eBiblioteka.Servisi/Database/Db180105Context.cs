using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace eBiblioteka.Servisi.Database;

public partial class Db180105Context : DbContext
{
    public Db180105Context()
    {
    }

    public Db180105Context(DbContextOptions<Db180105Context> options)
        : base(options)
    {
    }

    public virtual DbSet<Autor> Autors { get; set; }

    public virtual DbSet<Citaonica> Citaonicas { get; set; }

    public virtual DbSet<Clanarina> Clanarinas { get; set; }

    public virtual DbSet<Knjiga> Knjigas { get; set; }

    public virtual DbSet<KnjigaAutor> KnjigaAutors { get; set; }

    public virtual DbSet<Korisnik> Korisniks { get; set; }

    public virtual DbSet<KorisnikIzabranaKnjiga> KorisnikIzabranaKnjigas { get; set; }

    public virtual DbSet<KorisnikUloga> KorisnikUlogas { get; set; }

    public virtual DbSet<Recenzija> Recenzijas { get; set; }

    public virtual DbSet<Rezervacija> Rezervacijas { get; set; }

    public virtual DbSet<Termin> Termins { get; set; }

    public virtual DbSet<TipClanarine> TipClanarines { get; set; }

    public virtual DbSet<Uloga> Ulogas { get; set; }

    public virtual DbSet<Zanr> Zanrs { get; set; }

    //protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
//#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
//        => optionsBuilder.UseSqlServer("Data Source=.;Initial Catalog=db180105;Integrated Security=True;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Autor>(entity =>
        {
            entity.HasKey(e => e.AutorId).HasName("PK__Autor__F58AE929771A00DC");

            entity.ToTable("Autor");

            entity.Property(e => e.Ime).HasMaxLength(50);
            entity.Property(e => e.Prezime).HasMaxLength(50);
        });

        modelBuilder.Entity<Citaonica>(entity =>
        {
            entity.HasKey(e => e.CitaonicaId).HasName("PK__Citaonic__2AF2F8E5364443F1");

            entity.ToTable("Citaonica");

            entity.Property(e => e.Naziv).HasMaxLength(100);
        });

        modelBuilder.Entity<Clanarina>(entity =>
        {
            entity.HasKey(e => e.ClanarinaId).HasName("PK__Clanarin__C51E3B97DF546AA2");

            entity.ToTable("Clanarina");

            entity.Property(e => e.DatumIsteka).HasColumnType("datetime");
            entity.Property(e => e.DatumUplate).HasColumnType("datetime");
            entity.Property(e => e.StatusClanarine).HasMaxLength(50);

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Clanarinas)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__Clanarina__Koris__66603565");

            entity.HasOne(d => d.TipClanarine).WithMany(p => p.Clanarinas)
                .HasForeignKey(d => d.TipClanarineId)
                .HasConstraintName("FK__Clanarina__TipCl__6754599E");
        });

        modelBuilder.Entity<Knjiga>(entity =>
        {
            entity.HasKey(e => e.KnjigaId).HasName("PK__Knjiga__4A1281F337C344CF");

            entity.ToTable("Knjiga");

            entity.Property(e => e.Dostupna).HasDefaultValue(true);
            entity.Property(e => e.IsDeleted).HasDefaultValue(false);
            entity.Property(e => e.KnjigaDana).HasDefaultValue(false);
            entity.Property(e => e.Naziv).HasMaxLength(200);
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Zanr).WithMany(p => p.Knjigas)
                .HasForeignKey(d => d.ZanrId)
                .HasConstraintName("FK__Knjiga__ZanrId__3B75D760");
        });

        modelBuilder.Entity<KnjigaAutor>(entity =>
        {
            entity.HasKey(e => e.KnjigaAutorId).HasName("PK__KnjigaAu__7CCCDDD631B6011C");

            entity.ToTable("KnjigaAutor");

            entity.HasOne(d => d.Autor).WithMany(p => p.KnjigaAutors)
                .HasForeignKey(d => d.AutorId)
                .HasConstraintName("FK__KnjigaAut__Autor__4222D4EF");

            entity.HasOne(d => d.Knjiga).WithMany(p => p.KnjigaAutors)
                .HasForeignKey(d => d.KnjigaId)
                .HasConstraintName("FK__KnjigaAut__Knjig__412EB0B6");
        });

        modelBuilder.Entity<Korisnik>(entity =>
        {
            entity.HasKey(e => e.KorisnikId).HasName("PK__Korisnik__80B06D4145F9C87E");

            entity.ToTable("Korisnik");

            entity.Property(e => e.DatumBanovanja).HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.Ime).HasMaxLength(50);
            entity.Property(e => e.IsBanned).HasDefaultValue(false);
            entity.Property(e => e.KorisnickoIme).HasMaxLength(50);
            entity.Property(e => e.LozinkaHash).HasMaxLength(256);
            entity.Property(e => e.LozinkaSalt).HasMaxLength(256);
            entity.Property(e => e.Prezime).HasMaxLength(50);
            entity.Property(e => e.Telefon).HasMaxLength(15);
        });

        modelBuilder.Entity<KorisnikIzabranaKnjiga>(entity =>
        {
            entity.HasKey(e => e.KorisnikIzabranaKnjigaId).HasName("PK__Korisnik__08384791156793EB");

            entity.ToTable("KorisnikIzabranaKnjiga");

            entity.Property(e => e.DatumRezervacije).HasColumnType("datetime");
            entity.Property(e => e.DatumVracanja).HasColumnType("datetime");
            entity.Property(e => e.IsChecked).HasDefaultValue(false);

            entity.HasOne(d => d.Knjiga).WithMany(p => p.KorisnikIzabranaKnjigas)
                .HasForeignKey(d => d.KnjigaId)
                .HasConstraintName("FK__KorisnikI__Knjig__59063A47");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.KorisnikIzabranaKnjigas)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__KorisnikI__Koris__59FA5E80");
        });

        modelBuilder.Entity<KorisnikUloga>(entity =>
        {
            entity.HasKey(e => e.KorisnikUlogaId).HasName("PK__Korisnik__1608726EB57EC12B");

            entity.ToTable("KorisnikUloga");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.KorisnikUlogas)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__KorisnikU__Koris__4F7CD00D");

            entity.HasOne(d => d.Uloga).WithMany(p => p.KorisnikUlogas)
                .HasForeignKey(d => d.UlogaId)
                .HasConstraintName("FK__KorisnikU__Uloga__5070F446");
        });

        modelBuilder.Entity<Recenzija>(entity =>
        {
            entity.HasKey(e => e.RecenzijaId).HasName("PK__Recenzij__D36C607006F2FA35");

            entity.ToTable("Recenzija");

            entity.Property(e => e.Odobrena);

            entity.HasOne(d => d.Knjiga).WithMany(p => p.Recenzijas)
                .HasForeignKey(d => d.KnjigaId)
                .HasConstraintName("FK__Recenzija__Knjig__48CFD27E");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Recenzijas)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__Recenzija__Koris__49C3F6B7");
        });

        modelBuilder.Entity<Rezervacija>(entity =>
        {
            entity.HasKey(e => e.RezervacijaId).HasName("PK__Rezervac__CABA44DDB80F2209");

            entity.ToTable("Rezervacija");

            entity.Property(e => e.DatumRezervacije).HasColumnType("datetime");
            entity.Property(e => e.DatumVracanja).HasColumnType("datetime");
            entity.Property(e => e.Odobrena).HasDefaultValue(false);

            entity.HasOne(d => d.Knjiga).WithMany(p => p.Rezervacijas)
                .HasForeignKey(d => d.KnjigaId)
                .HasConstraintName("FK__Rezervaci__Knjig__534D60F1");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Rezervacijas)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__Rezervaci__Koris__5441852A");
        });

        modelBuilder.Entity<Termin>(entity =>
        {
            entity.HasKey(e => e.TerminId).HasName("PK__Termin__42126C95E3021893");

            entity.ToTable("Termin");

            entity.Property(e => e.JeRezervisan).HasDefaultValue(false);

            entity.HasOne(d => d.Citaonica).WithMany(p => p.Termins)
                .HasForeignKey(d => d.CitaonicaId)
                .HasConstraintName("FK__Termin__Citaonic__619B8048");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Termins)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__Termin__Korisnik__5FB337D6");
        });

        modelBuilder.Entity<TipClanarine>(entity =>
        {
            entity.HasKey(e => e.TipClanarineId).HasName("PK__TipClana__3414671F2F0B31B5");

            entity.ToTable("TipClanarine");

            entity.Property(e => e.VrijemeTrajanja).HasMaxLength(50);
        });

        modelBuilder.Entity<Uloga>(entity =>
        {
            entity.HasKey(e => e.UlogaId).HasName("PK__Uloga__DCAB23CBD74FA940");

            entity.ToTable("Uloga");

            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        modelBuilder.Entity<Zanr>(entity =>
        {
            entity.HasKey(e => e.ZanrId).HasName("PK__Zanr__953868D3F1CE1602");

            entity.ToTable("Zanr");

            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
