# Generated by Django 2.2.7 on 2020-02-11 09:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0022_insertar_unidades_organizativas'),
    ]

    operations = [
        migrations.AlterField(
            model_name='obra',
            name='codigo',
            field=models.CharField(db_column='codigo', help_text='Codigo de la obra', max_length=255, verbose_name='codigo'),
        ),
        migrations.AlterField(
            model_name='obra',
            name='codigo_estudio',
            field=models.CharField(help_text='código de estudio asociado', max_length=255, null=True, verbose_name='código de estudio'),
        ),
    ]