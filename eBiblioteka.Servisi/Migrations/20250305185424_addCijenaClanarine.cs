using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBiblioteka.Servisi.Migrations
{
    /// <inheritdoc />
    public partial class addCijenaClanarine : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "VrijemeTrajanja",
                table: "TipClanarine",
                type: "int",
                maxLength: 50,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50);

            migrationBuilder.AddColumn<int>(
                name: "Cijena",
                table: "TipClanarine",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Cijena",
                table: "TipClanarine");

            migrationBuilder.AlterColumn<string>(
                name: "VrijemeTrajanja",
                table: "TipClanarine",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int",
                oldMaxLength: 50);
        }
    }
}
